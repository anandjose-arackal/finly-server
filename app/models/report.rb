# == Schema Information
#
# Table name: reports
#
#  id                                 :integer          not null, primary key
#  name                               :string(255)      not null
#  user_id                            :integer          not null
#  report_status_id                   :integer          not null
#  policy_id                          :integer          not null
#  submitted_at                       :datetime
#  controlling_user_id                :integer
#  controlling_user_role_id           :integer
#  controlling_for_user_id            :integer
#  controlling_for_user_role_id       :integer
#  memo                               :string(255)
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  reimbursement_id                   :integer
#  accounted                          :boolean          default(FALSE), not null
#  archived                           :boolean          default(FALSE), not null
#  is_deleted                         :boolean          default(FALSE), not null
#  auto_submit                        :boolean          default(FALSE), not null
#  auto_approve                       :boolean          default(FALSE), not null
#  accounted_at                       :date
#  approved_at                        :datetime
#  cash_in_hand_deduction_id          :integer
#  submitted_amount_id                :integer
#  reimbursable_expenses_total_id     :integer
#  card_expenses_total_id             :integer
#  non_reimbursable_expenses_total_id :integer
#  sync_status_id                     :integer
#  sync_type_id                       :integer
#  report_processor_group_mapping_id  :integer
#  travel_request_id                  :integer
#  created_by_id                      :integer
#  department_id                      :integer
#  sub_department_id                  :integer
#





class Report < ActiveRecord::Base
  include MathUtil
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation,
          FindByOrderedIds

  has_many :email_authorizations, as: :authorizable
  belongs_to :user, inverse_of: :reports
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
  belongs_to :report_status
  belongs_to :reimbursement, class_name: 'Payment'
  belongs_to :reimbursable_expenses_total, class_name: 'Amount'
  belongs_to :non_reimbursable_expenses_total, class_name: 'Amount'
  belongs_to :card_expenses_total, class_name: 'Amount'
  belongs_to :cash_in_hand_deduction, class_name: 'Payment'
  belongs_to :cash_in_hand_deduction_amount, class_name: 'Amount'
  belongs_to :sync_status, class_name: 'ReportSyncStatus'
  belongs_to :report_processor_group_mapping
  belongs_to :sync_status, class_name: 'ReportSyncStatus'
  belongs_to :sync_type, class_name: 'ReportSyncType'
  belongs_to :travel_request
  belongs_to :department
  belongs_to :sub_department, class_name: "Department"

  has_many :custom_fields, as: :parent, dependent: :destroy

  # submission amount for determining the approving manager and finance manager
  belongs_to :submitted_amount, class_name: 'Amount'
  accepts_nested_attributes_for :submitted_amount
  accepts_nested_attributes_for :reimbursable_expenses_total
  accepts_nested_attributes_for :non_reimbursable_expenses_total
  accepts_nested_attributes_for :card_expenses_total
  accepts_nested_attributes_for :custom_fields

  validates :user, presence: true
  validate :is_employee
  validate :has_expenses
  validate :controller_has_role
  validates :policy_id, presence: true

  alias_attribute :purpose, :memo

  field_customization_key :report
  customizable_validate :purpose, presence: false, scope: [:user, :company]


  default_scope {order(report_status_id: :asc, submitted_at: :desc, created_at: :desc)}

  scope :with_id, ->(id) {where id: id}
  scope :filter_id, ->(id) {with_id(id)}
  scope :without_id, ->(id) {where.not id: id}
  scope :with_policy, ->(policy_id) {where policy_id: policy_id}
  scope :with_policy_id, ->(policy_id) {where policy_id: policy_id}
  scope :with_user, ->(user_id) {where user_id: user_id}
  scope :with_user_id, ->(user_id) {where user_id: user_id}
  scope :non_archived, -> {where.not archived: false}
  scope :archived, -> {where archived: true}
  scope :with_amount, -> {joins :reimbursable_expenses_total}
  scope :with_reimbursable_expenses_total, -> {joins :reimbursable_expenses_total}
  scope :with_non_reimbursable_expenses_total, -> {joins :non_reimbursable_expenses_total}
  scope :with_card_expenses_total, -> {joins :card_expenses_total}
  scope :with_status_id, ->(id) {where report_status_id: id}
  scope :open, -> {where report_status_id: ReportStatus.open_id}
  scope :approved, -> {where report_status_id: ReportStatus.approved_id}
  scope :closed, -> {where report_status_id: ReportStatus.closed_id}
  scope :submitted_after, ->(date) {where 'submitted_at > ?', date}
  scope :settled, -> {where report_status_id: ReportStatus.settled_id}
  scope :settlement_confirmed, -> {where report_status_id: ReportStatus.settlement_confirmed_id}
  scope :processing, -> {where report_status_id: ReportStatus.processing_id}
  scope :processing_and_above, -> {where report_status_id: [ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.approved_id, ReportStatus.closed_id, ReportStatus.processing_id]}
  scope :processed, -> {where report_status_id: [ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.approved_id, ReportStatus.closed_id]}
  scope :completed, -> {where report_status_id: [ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.closed_id]}
  scope :accounted, -> {where accounted: true}
  scope :owner, ->(user_id) {where user_id: user_id}
  scope :non_owner, ->(user_id) {where.not user_id: user_id}
  scope :with_controlling_user_role, -> (role_id) {where controlling_user_role_id: role_id}
  scope :not_open, -> {where.not report_status_id: ReportStatus.open_id}
  scope :include_user, -> {includes :user}
  scope :without_payment, -> {where reimbursement_id: nil}
  scope :pending_settlement, -> {where(report_status_id: ReportStatus.approved_id).where(accounted: false)}
  scope :with_controlling_user_id, ->(user_id) {where controlling_user_id: user_id}

  # todo - having issues, where amounts are not matching actual expense amounts
  scope :expenses_total, -> {joins(expenses: :amount).sum(:INR)}
  # todo - having issues, where amounts are not matching actual reimbursements amounts
  scope :expenses_reimbursable_total, -> do
    # joins(expenses: :amount).where('expenses.reimbursable = true').sum('amounts.INR')
    ids = pluck(:id)
    Expense.with_report_id(ids).reimbursable.sum_reimbursements
  end
  scope :group_user_id, -> {group 'reports.user_id'}
  scope :group_user, -> {group :user}
  scope :joins_user, -> {joins :user}
  scope :include_reimbursable_user_accounts, -> {includes user: [:bank_accounts, :reimbursement_cards]}
  scope :sort_by_updated_at, -> {unscope(:order).order(updated_at: :desc)}
  scope :without_associated_processor, -> {where report_processor_group_mapping_id: nil}

  scope :unsubmitted, -> {where(report_status_id: [ReportStatus.id_for(:open), ReportStatus.id_for(:retracted), ReportStatus.id_for(:retracted)])}

  scope :with_approved_at_range, -> (start_time, end_time) {where('approved_at >= ? and approved_at <= ?', start_time, end_time)}

  # scope for reports being shown in settlements page
  scope :settlement_viewable, -> {where report_status_id: [ReportStatus.approved_id, ReportStatus.settled_id, ReportStatus.closed_id, ReportStatus.settlement_confirmed_id]}

  scope :processed, -> {where report_status_id: [ReportStatus.approved_id, ReportStatus.settled_id, ReportStatus.closed_id, ReportStatus.settlement_confirmed_id]}
  scope :settled_and_closed, -> {where report_status_id: [ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.closed_id]}

  scope :filter_status, ->(status_id, user_id) do
    case status_id
    when 99, '99'
      where(controlling_user_id: user_id).where.not(report_status_id: ReportStatus.ids_for(:retracted, :open, :rejected))
    else
      where report_status_id: status_id
    end
  end
  scope :filter_user_id, ->(id) {where(user_id: id)}
  scope :filter_report_id, ->(id) {where(id: id)}
  scope :filter_search, ->(value) do
    # user_ids = self.pluck(:id)
    # user_ids = User.with_id(user_ids).where("name like :value OR email like :value", value: "%#{value}%").pluck(:id)
    reports = arel_table
    where(reports[:name].matches("%#{value}%").or(reports[:id].eq(value)))
  end
  scope :filter_mapping_id, -> (id) {where report_processor_group_mapping_id: id}
  scope :pluck_mapping_id, -> {pluck :report_processor_group_mapping_id}
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
  scope :filter_submitted_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      reports = arel_table
      where(reports[:submitted_at].gteq(date_from).and(reports[:submitted_at].lteq(date_to)))
    end
  end
  scope :filter_approved_date, ->(date_from = nil, date_to = nil) do
    # sample params: filter_date[expense, 2016-03-01, 2016-03-20]
    unless date_from.blank? && date_to.blank?
      date_from = "1990-01-01" if date_from.blank?
      date_to = "2100-01-01" if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date + 1 if date_to.present?
      # date_to = DateUtils.local_date if date_to.blank?
      reports = arel_table
      where(reports[:approved_at].gteq(date_from).and(reports[:approved_at].lteq(date_to)))
    end
  end
  scope :filter_policy, -> (policy_id) {where(policy_id: policy_id)}

  scope :sort_for_personal, -> {joins(:report_status).reorder('report_statuses.order ASC, reports.submitted_at DESC, reports.created_at DESC')}

  scope :order_by_controlling_user, ->(user_id, manager = false) {
    if user_id.present?
      ids = pluck(:id)
      controlling_reports = where(controlling_user_id: user_id)
      if manager
        controlling_reports = controlling_reports.where(report_status_id: ReportStatus.id_for(:processing))
      end
      controlling_ids = controlling_reports.pluck(:id)
      ordered_ids = controlling_ids + (ids - controlling_ids)
      find_ordered(ordered_ids)
    end
  }

  scope :order_by, ->(type, user_id = nil) {
    case type
    when :created_at
      reorder(created_at: :desc)
    when :manager_controlling_user
      order_by_controlling_user(user_id, true)
    when :controlling_user
      order_by_controlling_user(user_id)
    when :submitted_at
      reorder(submitted_at: :desc)
    end
  }

  scope :awaiting_approval_of_user, ->(user_id, role_id) {where(report_status_id: ReportStatus.id_for(:processing)).where(controlling_user_id: user_id).where(controlling_user_role_id: role_id)}
  scope :not_destroyable, -> {where.not report_status_id: ReportStatus.ids_for([:open, :rejected, :retracted])}
  scope :without_user, -> (user_id) {where.not user_id: user_id}

  scope :includes_export, -> {includes({expenses: [:category, :user, {report: [:status, policy: [distance_expense_config: [:rate]]]},
                                                   :expense_type, {manual_expense: [custom_fields: [:field_configuration, :value]]},
                                                   {card_expense: [custom_fields: [:field_configuration]]},
                                                   {distance_expense: [{distance: [:physical_unit]}, {maps_distance: [:physical_unit]}, :locations, custom_fields: [:field_configuration]]},
                                                   {time_expense: [custom_fields: [:field_configuration]]},
                                                   {per_diem_expense: [per_diem: [:configurable, rate: [:currency]], custom_fields: [:field_configuration]]},
                                                   {amount: [:currency]}, :expense_status]}, :status, policy: [distance_expense_config: [:rate]])}

  scope :includes_user, -> {includes :user}
  scope :includes_tracks, -> {includes :tracks}
  scope :includes_policy, -> {includes :policy}
  scope :not_settled, -> {where report_processor_group_mapping_id: nil}
  scope :with_processor_group_mapping, -> (id) {where report_processor_group_mapping_id: id}
  scope :include_details, -> {includes :user, :controlling_user, :policy}

  scope :filter_custom_drop_down_selection, ->(drop_down_item_id) do
    drop_down_selection_ids = FieldDropDownSelection.with_value(drop_down_item_id).pluck(:id)
    configs = CustomField.with_drop_down_selection(drop_down_selection_ids).includes_parent.with_parent_report
    report_ids = configs.map {|item| item.parent&.id}
    with_id(report_ids)
  end

  scope :filter_category, -> (category_id) {
    ids = self.pluck(:id)
    report_ids = Expense.with_report_id(ids).where(category_id: category_id).pluck(:report_id)
    where(id: report_ids)
  }

  scope :filter_group, -> (group_ids) {
    user_group_item_ids = group_ids
    original_report_ids = self.pluck(:id)
    user_ids = UserGroupItemMapping.where(user_group_item_id: user_group_item_ids).pluck(:user_id)
    ids = Report.where(id: original_report_ids, user_id: user_ids).pluck(:id)
    where(id: ids)
  }

  scope :with_budgetable_user_ids, -> (user_ids) {
    if user_ids.present?
      where user_id: user_ids
    end
  }

  scope :with_budgetable_department_ids, -> (department_ids) {
    if department_ids.present?
      ids = where(department_id: department_ids).pluck(:id)
      ids = where(sub_department_id: department_ids).pluck(:id)
      where(id: ids)
    end
  }

  delegate :status_name, to: :status

  delegate :submitted_amount_value, to: :submitted_amount

  before_save :handle_name

  before_destroy :clear_expenses

  after_save :budget_trail_entry

  after_destroy :budget_trail_destroy

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

  def settled?
    self.status_id == ReportStatus.settled_id
  end

  def settlement_confirmed?
    self.status_id == ReportStatus.settlement_confirmed_id
  end

  def closed?
    self.status_id == ReportStatus.closed_id
  end

  def editable?
    open? or retracted? or rejected?
  end

  def processed?
    if [ReportStatus.approved_id, ReportStatus.settled_id, ReportStatus.settlement_confirmed_id, ReportStatus.closed_id].include?(self.report_status_id)
      return true
    end
  end

  def settlement_pending?
    approved? # (todo - temporary, till the cash on hand workflow is fixed) and reimbursable_expenses_total.present? and reimbursable_expenses_total.value > 0
  end

  def can_submit?
    open? or retracted? or rejected?
  end

  def can_retract?
    processing? or (approved? and auto_approve) or (closed? and auto_approve)
  end

  def can_destroy?
    # same as can_submit
    can_submit?
  end

  def can_archive?
    settled? or settlement_confirmed? or closed?
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

  def total_amount(types = [], options = {})
    return 0 unless self.expenses.present?
    temp_expenses = self.expenses
    if types.present?
      types = [types] unless types.kind_of?(Array)
      if types.present?
        types.each do |item|
          temp_expenses = temp_expenses.send(item.to_sym) if item.present? and temp_expenses.respond_to?(item.to_sym)
        end
      end
    end
    currency_code = options&.dig(:currency_code) || self.base_currency_code
    precision_value(temp_expenses.with_amount.sum(currency_code.to_sym))
  end

  def reimbursable_expenses(options = {})
    total_amount([:reimbursable], options) - total_tds_amount(options)
  end

  def non_reimbursable_expenses(options = {})
    total_amount([:non_reimbursable], options)
  end

  def total_tds_amount(options = {})
    currency_code = options&.dig(:currency_code) || self.base_currency_code
    self.expenses.with_expense_tax_type_id(ExpenseTaxType.ids_for(:gst_tds, :tds)).sum_tds_amounts(currency_code)
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
    return nil unless self.approved? or self.settled? or self.settlement_confirmed? or self.closed?
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

  def require_settlement?
    report_total = total_amount
    latest_exp = latest_expense
    date = nil
    date = latest_exp.date if latest_exp.present?
    cash = self.user.cash_in_hand date
    cash.value - report_total < 0
  end

  def base_currency
    self.policy.base_currency
  end

  def base_currency_id
    self.policy.base_currency_id
  end

  def base_currency_code
    self.policy.base_currency.country_code
  end

  def base_currency_symbol
    self.policy.base_currency.symbol
  end

  def settlement_currency
    self.policy.settlement_currency
  end

  def settlement_currency_id
    self.policy.settlement_currency_id
  end

  def settlement_currency_code
    self.policy.settlement_currency.country_code
  end

  def settlement_currency_symbol
    self.policy.settlement_currency.symbol
  end

  def only_card_expenses?
    self.expenses.count == self.expenses.only_card_expenses.count
  end

  def only_cash_on_hand_expenses?
    self.expenses.count == self.expenses.spent_from_cash_on_hand.count
  end

  def synced_with_quickbooks?
    self.sync_status_id == ReportSyncStatus.id_for(:synced)
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

  def budget_trail_entry
    # if this expense was somehow removed from a report, or the report was updated in anyway, we update its entry in the BudgetTrail model
    if ReportStatus.ids_for([:open, :retracted, :rejected]).include?(self.report_status_id)
      self.expenses.each do |expense|
        BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.destroy_trail(expense)
      end
    else
      self.expenses.each do |expense|
        BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.save_trail(expense)
      end
    end
  end

  def budget_trail_destroy
    self.expenses.each do |expense|
      BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.destroy_trail(expense)
    end
  end

end
