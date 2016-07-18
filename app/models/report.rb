# == Schema Information
#
# Table name: reports
#
#  id                      :integer          not null, primary key
#  name                    :string(255)      not null
#  user_id                 :integer          not null
#  report_status_id        :integer          not null
#  policy_id               :integer
#  submitted_at            :datetime
#  controlling_user_id     :integer
#  controlling_for_user_id :integer
#  forwarding_to_id        :integer
#  memo                    :string(255)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  reimbursement_id        :integer
#  reimbursement_amount_id :integer
#  accounted               :boolean          default(FALSE), not null
#  archived                :boolean          default(FALSE), not null
#

class Report < ActiveRecord::Base
  belongs_to :user
  belongs_to :status, class_name: 'ReportStatus', foreign_key: :report_status_id
  belongs_to :policy
  belongs_to :controlling_user, class_name: 'User'
  belongs_to :controlling_for_user, class_name: 'User'
  has_many :tracks, class_name: 'ReportTrack', dependent: :destroy
  has_many :expenses
  has_many :comments, class_name: 'ReportComment', dependent: :destroy
  has_many :receipts, as: :parent
  belongs_to :reimbursement, class_name: 'Payment'
  belongs_to :reimbursement_amount, class_name: 'Amount'

  validates :user, presence: true
  validates :status, presence: true

  scope :with_id, ->(id) { where id: id }
  scope :non_archived, -> { where.not archived: false }
  scope :archived, -> { where archived: true }
  scope :with_amount, -> { joins :reimbursement_amount }
  scope :approved, -> { where report_status_id: ReportStatus.approved_id }
  scope :submitted_after, ->(date) { where 'submitted_at > ?', date }
  scope :reimbursed, -> { where report_status_id: ReportStatus.reimbursed_id }
  scope :reimbursement_confirmed, -> { where report_status_id: ReportStatus.reimbursement_confirmed_id }
  scope :accounted, -> { where accounted: true }

  before_save do
    if self.name.blank?
      self.name = Report.get_default_name(self.user)
    end
  end

  before_destroy do
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

  # Used to retrieve all the users associated with this report. If user before is provided,
  # it provides a list of all users who interacted with the report before this given user. Mainly used for reject_to
  def associated_users(user_before = nil, ordered = false)
    return nil if tracks.blank?
    trackings = tracks.without_take_control_action
    if user_before.present?
      track = trackings.find_by(action_user_id: user_before.id)
      unless track.blank?
        trackings = trackings.created_before(track.created_at)
      end
    end
    user_ids = trackings.map(&:action_user_id).uniq
    if controlling_user_id.present? and (user_before.blank? or user_before.id != controlling_user_id)
      if controlling_for_user_id.present?
        user_ids << controlling_for_user_id
      else
        user_ids << controlling_user_id
      end
    end
    if user_ids.size > 0
      # Order is MySQL Specific
      user_ids = user_ids.reverse!
      user_ids.reject! { |id| id.blank? }
      return User.where(id: user_ids).where(company_id: self.user.company_id).order("field(id,#{user_ids.join(',')})")
    end
    nil
  end

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

  def reimbursement_pending?
    approved? and reimbursement_amount.present? and reimbursement_amount.value > 0
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

end
