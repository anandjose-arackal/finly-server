# == Schema Information
#
# Table name: reports
#
#  id                           :integer          not null, primary key
#  name                         :string(255)      not null
#  user_id                      :integer          not null
#  report_status_id             :integer          not null
#  policy_id                    :integer
#  submitted_at                 :datetime
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  memo                         :string(255)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  reimbursement_id             :integer
#  reimbursement_amount_id      :integer
#  accounted                    :boolean          default(FALSE), not null
#  archived                     :boolean          default(FALSE), not null
#  is_deleted                   :boolean          default(FALSE), not null
#  auto_submit                  :boolean          default(FALSE), not null
#  auto_approve                 :boolean          default(FALSE), not null
#  accounted_at                 :date
#  approved_at                  :datetime
#





class Report < ActiveRecord::Base
  include MathUtil
  include SoftDeletable

  belongs_to :user
  belongs_to :status, class_name: 'ReportStatus', foreign_key: :report_status_id
  belongs_to :policy
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_user_role, class_name: 'UserRole'
  belongs_to :controlling_for_user, class_name: 'User'
  belongs_to :controlling_for_user_role, class_name: 'UserRole'
  has_many :tracks, class_name: 'ReportTrack', dependent: :destroy
  has_many :expenses
  has_many :comments, class_name: 'ReportComment', dependent: :destroy
  has_many :receipts, as: :parent
  # Payment made as reimbursement
  belongs_to :reimbursement, class_name: 'Payment'
  belongs_to :reimbursement_amount, class_name: 'Amount'
  belongs_to :cash_in_hand_deduction, class_name: 'Payment'
  belongs_to :cash_in_hand_deduction_amount, class_name: 'Amount'

  validates :user, presence: true
  validates :status, presence: true
  validate :is_employee
  validate :has_expenses
  validate :controller_has_role

  default_scope { order(report_status_id: :asc, submitted_at: :desc, created_at: :desc) }

  scope :with_id, ->(id) { where id: id }
  scope :without_id, ->(id) { where.not id: id }
  scope :with_policy, ->(policy_id) { where policy_id: policy_id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :non_archived, -> { where.not archived: false }
  scope :archived, -> { where archived: true }
  scope :with_amount, -> { joins :reimbursement_amount }
  scope :with_reimbursement_amount, -> {joins :reimbursement_amount}
  scope :open, -> { where report_status_id: ReportStatus.open_id }
  scope :approved, -> { where report_status_id: ReportStatus.approved_id }
  scope :closed, -> { where report_status_id: ReportStatus.closed_id }
  scope :submitted_after, ->(date) { where 'submitted_at > ?', date }
  scope :reimbursed, -> { where report_status_id: ReportStatus.reimbursed_id }
  scope :reimbursement_confirmed, -> { where report_status_id: ReportStatus.reimbursement_confirmed_id }
  scope :processing, -> { where report_status_id: ReportStatus.processing_id }
  scope :processed, -> { where report_status_id: [ReportStatus.reimbursed_id, ReportStatus.reimbursement_confirmed_id, ReportStatus.approved_id, ReportStatus.closed_id] }
  scope :accounted, -> { where accounted: true }
  scope :owner, ->(user_id) { where user_id: user_id }
  scope :non_owner, ->(user_id) { where.not user_id: user_id }
  scope :with_controlling_user_role, -> (role_id) { where controlling_user_role_id: role_id }
  scope :not_open, -> { where.not report_status_id: ReportStatus.open_id }
  scope :include_user, -> { includes :user }
  scope :without_payment, -> { where reimbursement_id: nil }
  scope :pending_reimbursement, -> {where(report_status_id: ReportStatus.approved_id).where(accounted: false)}
  scope :with_controlling_user_id, ->(user_id) {where controlling_user_id: user_id}

  # scope for reports being shown in settlements page
  scope :settlement_viewable, -> {where report_status_id: [ReportStatus.approved_id, ReportStatus.reimbursed_id, ReportStatus.closed_id, ReportStatus.reimbursement_confirmed_id]}

  scope :filter_status, ->(status_id) { where report_status_id: status_id }
  scope :filter_user_id, ->(id) { where(user_id: id) }
  scope :filter_report_id, ->(id) { where(id: id) }
  scope :filter_search, ->(value) do
    user_ids = self.pluck(:id)
    user_ids = User.with_id(user_ids).where("name like :value OR email like :value", value: "%#{value}%").pluck(:id)
    reports = arel_table
    where(reports[:name].matches("%#{value}%").or(reports[:user_id].in(user_ids)).or(reports[:id].eq(value)))
  end
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      reports = arel_table
      where(reports[:created_at].gteq(date_from).and(reports[:created_at].lteq(date_to)))
    end
  end
  scope :filter_policy, -> (policy_id) { where(policy_id: policy_id) }

  delegate :status_name, to: :status

  before_save :handle_name

  before_destroy :clear_expenses

  attr_accessor :cache_users

  def self.get_default_name(user)
    "#{user.name.downcase.split.join('_')}_#{Time.now.strftime("%d.%m.%y")}"
  end

  def status_id
    self.report_status_id
  end

  def open?
    self.status_id == ReportStatus.open_id
  end

  def retracted?
    self.status_id == ReportStatus.retracted_id
  end

  def rejected?
    self.status_id == ReportStatus.rejected_id
  end

  def processing?
    self.status_id == ReportStatus.processing_id
  end

  def approved?
    self.status_id == ReportStatus.approved_id
  end

  def reimbursed?
    self.status_id == ReportStatus.reimbursed_id
  end

  def reimbursement_confirmed?
    self.status_id == ReportStatus.reimbursement_confirmed_id
  end

  def closed?
    self.status_id == ReportStatus.closed_id
  end

  def editable?
    open? or retracted? or rejected?
  end

  def reimbursement_pending?
    approved? and reimbursement_amount.present? and reimbursement_amount.value > 0
  end

  def can_submit?
    open? or retracted? or rejected?
  end

  def can_destroy?
    # same as can_submit
    can_submit?
  end

  def can_archive?
    reimbursed? or reimbursement_confirmed? or closed?
  end

  def can_unapprove?
    processing? or approved? or closed?
  end

  def can_take_control?
    processing?
  end

  def archived?
    self.archived
  end

  def accounted?
    self.accounted
  end

  def relative_status_name(user)
    if processing? and controlling_user? user
      return 'Pending Review'
    end
    name = status.name
    name[0].upcase + name[1..name.length]
  end


  def total_amount(options=[])
    return 0 unless self.expenses.present?
    temp_expenses = self.expenses
    if options.present?
      options = [options] unless options.kind_of?(Array)
      if options.present?
        options.each do |item|
          temp_expenses = self.expenses.send(item.to_sym) if item.present? and self.expenses.respond_to?(item.to_sym)
        end
      end
    end
    precision_value(temp_expenses.with_amount.sum(:value))
  end

  def controlling_user?(user)
    return false if self.controlling_user_id.blank?
    self.controlling_user.id == user.id
  end

  def versioned_policy
    if self.submitted_at.present?
      if self.policy
        return self.policy.version_at self.submitted_at, has_many: true, has_one: true, belongs_to: true
      end
    end
    self.policy
  end

  def final_approver
    return nil unless self.approved? or self.reimbursed? or self.reimbursement_confirmed? or self.closed?
    tracks = self.tracks.with_action(ReportTrackingAction.id_for(:approve))
    if tracks.present?
      return tracks.last.action_user
    end
    nil
  end

  def first_date
    return nil unless self.expenses.count > 0
    expenses.sort_date_asc.first.date
  end

  def last_date
    return nil unless expenses.count > 0
    expenses.sort_date_desc.first.date
  end

  def date_as_string
    d_start = first_date
    d_end = last_date
    if d_start.blank? and d_end.blank?
      return ''
    end
    if d_start == d_end
      return "#{d_start.strftime("%d-%b-%y")}"
    else
      return "#{d_start.strftime("%d-%b-%y")} to #{d_end.strftime("%d-%b-%y")}"
    end
  end

  def latest_expense
    return nil unless self.expenses.count > 0
    self.expenses.sort_date_desc.first
  end

  def require_reimbursement?
    report_total = total_amount
    latest_exp = latest_expense
    date = nil
    date = latest_exp.date if latest_exp.present?
    cash = self.user.cash_in_hand date
    cash.value - report_total < 0
  end

  private

  def controller_has_role
    if controlling_user_id.present?
      unless controlling_user_role_id.present?
        errors.add(:report, 'cannot be processed')
      end
    end
  end

  def is_employee
    unless self.user.employee?
      errors.add(:User, 'is not allowed to create reports')
    end
  end

  def handle_name
    if self.name.blank?
      self.name = Report.get_default_name(self.user)
    end
  end

  def has_expenses
    if report_status_id_changed? and report_status_id_was.present? and
        (report_status_id_was == ReportStatus.open_id or report_status_id_was == ReportStatus.retracted_id) and
        (report_status_id == ReportStatus.processing_id or report_status_id == ReportStatus.closed_id)
      unless expenses.present?
        errors.add :cannot, 'submit an empty report'
      end
    end
  end

  def clear_expenses
    if self.expenses.present?
      expenses.each do |expense|
        expense.update_attributes report_id: nil, expense_status_id: ExpenseStatus.unreported_id
      end
      receipts.each do |receipt|
        receipt.parent_id = receipt.parent_type = nil
        receipt.save
      end
    end
  end

end
