# == Schema Information
#
# Table name: expenses
#
#  id                     :integer          not null, primary key
#  amount_id              :integer
#  expense_status_id      :integer
#  note                   :text(65535)
#  date                   :date
#  user_id                :integer
#  expense_type_id        :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  manager_memo           :text(65535)
#  rejecting_manager_id   :integer
#  report_id              :integer
#  category_id            :integer
#  is_deleted             :boolean          default(FALSE), not null
#  transcribed            :boolean          default(FALSE)
#  personal               :boolean          default(FALSE)
#  reimbursable           :boolean
#  synced_with_quickbooks :boolean          default(FALSE)
#  split_link             :string(255)
#  deleted_to_split       :boolean          default(FALSE)
#  from_cash_on_hand      :boolean          default(FALSE)
#  cash_on_hand_blocked   :boolean
#  expense_tax_type_id    :integer
#  gst_percentage         :decimal(10, )
#  tds_percentage         :decimal(10, )
#  tds_amount_id          :integer
#  gst_type_id            :integer
#  tds_slab_id            :integer
#  gst_amount_id          :integer
#  usage_date_start       :datetime
#  usage_date_end         :datetime
#  usage_date_type        :string(255)
#  spent_from_id          :integer
#  custom_conversion_rate :boolean          default(FALSE)
#





class Expense < ActiveRecord::Base
  include SoftDeletable,
          FieldCustomizer::CustomizableValidation,
          MathUtil

  belongs_to :amount
  belongs_to :expense_status
  belongs_to :user, inverse_of: :expenses
  belongs_to :expense_type
  belongs_to :category
  belongs_to :report
  belongs_to :rejecting_manager, class_name: 'User'
  belongs_to :surcharge, class_name: 'Amount'
  belongs_to :tds_amount, class_name: 'Amount'
  belongs_to :gst_amount, class_name: 'Amount'
  belongs_to :expense_tax_type
  belongs_to :gst_type
  belongs_to :tds_slab, class_name: 'TdsRatesList'
  belongs_to :spent_from, class_name: 'UserPocket'

  has_many :receipts, as: :parent
  has_many :system_messages, as: :messagable, dependent: :destroy

  # link to budget trails table
  has_many :budget_trails, as: :entity

  has_many :duplicate_expense_mappings, foreign_key: :expense_id, dependent: :destroy
  has_many :duplicate_expenses, through: :duplicate_expense_mappings
  has_many :is_duplicate_expense_mappings, class_name: 'DuplicateExpenseMapping', foreign_key: :duplicate_expense_id, dependent: :destroy

  has_one :manual_expense, dependent: :destroy
  has_one :card_expense, dependent: :destroy
  has_one :distance_expense, dependent: :destroy
  has_one :time_expense, dependent: :destroy
  has_one :per_diem_expense, dependent: :destroy
  has_one :receipt_email
  has_one :payment, as: :reference_resource

  accepts_nested_attributes_for :system_messages
  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :manual_expense
  accepts_nested_attributes_for :card_expense
  accepts_nested_attributes_for :receipts
  accepts_nested_attributes_for :distance_expense
  accepts_nested_attributes_for :time_expense
  accepts_nested_attributes_for :per_diem_expense
  accepts_nested_attributes_for :receipt_email
  accepts_nested_attributes_for :tds_amount


  # delegating to associated classes the dependent attribute calls
  # delegate :amount_value, :currency, to: :amount
  delegate :surcharge_value, to: :card_expense
  delegate :expense_type_name, to: :expense_type
  delegate :expense_status_name, to: :expense_status
  delegate :user_name, to: :user
  delegate :manual?, :card?, :distance?, :time?, :per_diem?, to: :expense_type

  validates :date, presence: true
  validates :category_id, presence: true
  validates :expense_type_id, presence: true
  validates :user_id, presence: true
  validates :usage_date_type, allow_nil: true, :inclusion => {:in => ['hotel', 'usage', 'none', nil]}
  validates_presence_of :spent_from_id, message: 'Please select a Spend Account to create an expense', if: Proc.new { |exp| !exp.card_expense?}
  validate :validate_usage_dates
  validate :no_future_date
  validate :valid_expense_type
  validate :valid_amount_value
  validate :at_least_one_type

  alias_attribute :purpose, :note

  field_customization_key :expense
  customizable_validate :purpose, presence: false, scope: [:user, :company]
  customizable_validate :spent_from, presence: false, scope: [:user, :company], if: :check_spent_from?

  # i.e. an expense associated with a report can't be destroyed
  before_destroy do
    errors.add(:expense, "associated with a report can't be destroyed.") if self.report_id

    self.receipts.update_all(to_be_transcribed: false, parent_id: nil, parent_type: nil) if self.receipts.present?
  end

  before_save do
    if self.expense_status_id.blank?
      if self.report_id.blank?
        self.expense_status_id = ExpenseStatus.unreported_id
      else
        self.expense_status_id = ExpenseStatus.unsubmitted_id
      end
    end
    if card_expense?
      self.reimbursable = false
      self.from_cash_on_hand = false
    elsif self.spent_from&.reimbursement?
      self.reimbursable = true
      self.from_cash_on_hand = false
    elsif self.spent_from&.paid_by_company? or self.spent_from&.credit_card_pocket?
      self.reimbursable = false
      self.from_cash_on_hand = false
    else
      self.reimbursable = false
      self.from_cash_on_hand = true

    end
    compute_gst_amount
    compute_tds_amount
  end

  after_save :budget_trail_entry

  default_scope {order('expenses.created_at DESC')}

  scope :with_id, -> (ids) {where id: ids}

  scope :non_personal, -> {
    where(personal: false)
  }
  scope :personal, -> {
    where personal: true
  }

  scope :non_cancelled, -> {
    ids = pluck(:id)
    card_expenses = CardExpense.with_expense_id(ids)
    cancelled_expense_ids = card_expenses.where('cancelled IS true').pluck(:expense_id)
    non_cancelled_ids = ids - cancelled_expense_ids
    with_id(non_cancelled_ids)
  }

  scope :cancelled, -> {
    ids = pluck(:id)
    card_expenses = CardExpense.with_expense_id(ids)
    cancelled_expense_ids = card_expenses.where('cancelled IS true').pluck(:expense_id)
    with_id(cancelled_expense_ids)
  }

  scope :reimbursable, -> {where reimbursable: true}
  scope :non_reimbursable, -> {where reimbursable: false}

  scope :quickbooks_non_reimbursable, -> {where reimbursable: [false, nil]}

  scope :filter_expense_cancelled, -> (flag) {
    if flag == '1'
      cancelled
    else
      # do nothing, ha
    end
  }

  scope :filter_expense_personal, -> (flag) {
    if flag == '1'
      personal
    else
      # do nothing, ha
    end

  }

  scope :filter_field_configuration, ->(config_id) do
    configs = CustomField.with_field_configuration_ids(config_id).includes_parent.expenses
    expense_ids = configs.map {|item| item.parent&.expense_id}
    with_id(expense_ids)
  end

  scope :filter_custom_drop_down_selection, ->(drop_down_item_id) do
    drop_down_selection_ids = FieldDropDownSelection.with_value(drop_down_item_id).pluck(:id)
    configs = CustomField.with_drop_down_selection(drop_down_selection_ids).includes_parent.expenses
    expense_ids = configs.map {|item| item.parent&.expense_id}
    with_id(expense_ids)
  end

  scope :with_amount, -> {joins :amount}
  scope :joins_amount, -> {joins :amount}
  scope :having_amount_currency, -> (amount, currency_id) {with_amount.where('amounts.value IN (?) AND amounts.currency_id IN (?)', amount, currency_id)}
  scope :with_report, ->(report_id) {where report_id: report_id}
  scope :with_report_id, ->(report_id) {where report_id: report_id}
  scope :with_user, ->(user_id) {where user_id: user_id}
  scope :with_user_id, ->(user_id) {where user_id: user_id}
  scope :with_user_or_report, ->(user_id, report_id) {where 'user_id IN (?) OR report_id IN (?)', user_id, report_id}
  scope :date_before, -> (date) {where 'date < ?', date}
  scope :without_usage_date_type, -> {where usage_date_type: nil}
  scope :with_usage_date_type, -> {where.not usage_date_type: nil}
  scope :usage_date_within, ->(start_date, end_date) {where.not('usage_date_start > ? OR usage_date_end < ? ', end_date, start_date)}
  # scope :with_user_for_admin, ->(user_ids) { where('user_id IN (?) AND expense_type_id = ? AND expense_status_id = ?', user_ids, ExpenseType.card_expense_id, ExpenseStatus.submitted_id).uniq }
  scope :filter_expense_type_id, ->(type_id) do
    type_id = [type_id] unless type_id.is_a?(Array)
    diff_arr = (type_id - [1, 2, 3, 4, 5, '1', '2', '3', '4', '5'])
    diff_arr_cancelled = (type_id - [6, '6'])
    diff_arr_personal = (type_id - [7, '7'])
    if diff_arr and diff_arr.size == 0
      where expense_type_id: type_id
    elsif diff_arr_cancelled.size == 0
      ids = pluck(:id)
      card_expenses = CardExpense.with_expense_id(ids)
      cancelled_expense_ids = card_expenses.where('cancelled IS true').pluck(:expense_id)
      with_id(cancelled_expense_ids)
    elsif diff_arr_personal.size == 0
      personal
    end
  end

  # scopes for the filters
  scope :filter_amount, -> (type, value) do
    case type
    when 'lteq'
      joins(:amount).select('expenses.*').where('value <= ?', value)
    when 'gteq'
      joins(:amount).select('expenses.*').where('value >= ?', value)
    when 'eq'
      joins(:amount).select('expenses.*').where('ROUND(value, 2) = ?', precision_value(value))
    else
      # do nothing
    end
  end

  scope :filter_sort, ->(sort_by, order) do
    # order("#{sort_by} #{order}") # sort_by: created_at, date etc. order: asc/desc
    direction = order&.downcase == 'asc' ? 'asc' : 'desc'
    column = sanitize_sql(sort_by)

    order("#{column} #{direction}")

  end
  scope :filter_date, ->(date_from = nil, date_to = nil) do
    unless date_from.blank? && date_to.blank?
      type_val = :date
      date_from = "1990-01-01" if date_from.blank?
      date_to = DateUtils.local_date if date_to.blank?
      date_from = date_from.to_date if date_from.present?
      date_to = date_to.to_date if date_to.present?
      expenses = arel_table
      where(expenses[type_val].gteq(date_from).and(expenses[type_val].lteq(date_to)))
    end
  end
  scope :filter_category_id, -> (category_id) {
    if category_id
      where category_id: category_id
    end
  }

  scope :filter_merchant, -> (merchant_name) do
    expense_ids = ManualExpense.where('merchant like ?', "%#{merchant_name}%").pluck(:expense_id)
    expense_ids += CardExpense.where('editable_merchant like ?', "%#{merchant_name}%").pluck(:expense_id)
    expense_ids += PerDiemExpense.joins(:per_diem).where('per_diems.name LIKE ?', "%#{merchant_name}%").pluck(:expense_id)
    where(id: expense_ids)
  end

  # scope :filter_merchant, -> (merchant_name) {
  #   joins(:manual_expense, :card_expense).select('expenses.*').where('lower(merchant) like ? OR lower(editable_merchant) like ?', "%#{merchant_name}%", "%#{merchant_name}%")
  # }

  scope :filter_status_id, -> (status_id) {where expense_status_id: status_id}
  scope :filter_search, -> (value) do
    expense_ids = ManualExpense.where('merchant like ?', "%#{value}%").pluck(:expense_id)
    expense_ids += CardExpense.where('editable_merchant like ?', "%#{value}%").pluck(:expense_id)
    expense_ids += PerDiemExpense.joins(:per_diem).where('per_diems.name LIKE ?', "%#{value}%").pluck(:expense_id)

    where('id IN (?) OR note like ?', expense_ids, "%#{value}%")
    # joins(:card_expense).joins(:manual_expense).joins(:amount).select('expenses.*').where('editable_merchant like ? or merchant like ? OR note like ?', "%#{value}%", "%#{value}%", "%#{value}%")
  end

  # scope for analytics
  scope :filter_expense_status_id, -> {}

  scope :filter_receipt, -> (value) do
    expense_ids = Receipt.where(parent_type: Expense).uniq.pluck(:parent_id)
    case value
    when 'present'
      where(id: expense_ids)
    when 'absent'
      where.not(id: expense_ids)
    end
  end

  scope :manual, -> {joins(:manual_expense)}
  scope :card, -> {joins(:card_expense)}

  scope :group_by_category_id, -> {group :category_id}

  scope :only_card_expenses, -> {where(expense_type_id: ExpenseType.id_for(:card))}
  scope :except_card_expenses, -> {where.not(expense_type_id: ExpenseType.id_for(:card))}
  scope :only_manual_expenses, -> {where(expense_type_id: ExpenseType.id_for(:manual))}
  scope :only_distance_expenses, -> {where(expense_type_id: ExpenseType.id_for(:distance))}
  scope :only_time_expenses, -> {where(expense_type_id: ExpenseType.id_for(:time))}
  scope :only_per_diem_expenses, -> {where(expense_type_id: ExpenseType.id_for(:per_diem))}
  scope :only_reimbursable_expense_types, -> {where(expense_type_id: [ExpenseType.id_for(:manual),
                                                                      ExpenseType.id_for(:distance),
                                                                      ExpenseType.id_for(:time),
                                                                      ExpenseType.id_for(:per_diem)])}
  scope :only_reimbursable_expenses, -> {where(reimbursable: true)}
  scope :spent_from_cash_on_hand, -> {
    where(from_cash_on_hand: true)
  }
  scope :blocked_against_cash_on_hand, -> {where from_cash_on_hand: true}

  scope :with_id, ->(ids) {where id: ids}
  scope :without_id, -> (id) {
    if id.present?
      where.not(id: id)
    end
  }
  scope :with_date, ->(dates) {where date: dates}
  scope :with_date_range, -> (start_date, end_date) {where('date >= ? AND date <= ?', start_date, end_date)}
  scope :with_amount, -> {joins(:amount).select('expenses.*, amounts.*')}
  scope :unreported_and_rejected, -> {where expense_status_id: [ExpenseStatus.unreported_id, ExpenseStatus.rejected_id]}
  scope :submitted, -> {where expense_status_id: ExpenseStatus.submitted_id}
  scope :unreported, -> {where expense_status_id: ExpenseStatus.unreported_id}
  scope :rejected, -> {where expense_status_id: ExpenseStatus.rejected_id}
  scope :unsubmitted, -> {where expense_status_id: ExpenseStatus.unsubmitted_id}
  scope :admin_viewable, -> {where expense_status_id: [ExpenseStatus.id_for(:unsubmitted), ExpenseStatus.id_for(:rejected), ExpenseStatus.id_for(:unreported)]}
  scope :sort_date_desc, -> {order 'date DESC'}
  scope :sort_date_asc, -> {order 'date ASC'}
  scope :with_category, ->(category_id) {where category_id: category_id}
  scope :include_manual_expense, -> {joins :manual_expense}
  scope :filter_user_id, ->(id) {where user_id: id}
  scope :with_status_id, -> (id) {where status_id: id}

  scope :transcribed, -> {where transcribed: true}
  scope :untranscribed, -> {where transcribed: false}
  scope :limit_to, ->(count) {limit count}

  scope :verified, -> {where expense_status_id: ExpenseStatus.id_for(:verified)}
  scope :unreported, -> {where expense_status_id: ExpenseStatus.ids_for([:unreported, :unsubmitted, :rejected])}
  scope :reported, -> {where expense_status_id: ExpenseStatus.ids_for([:submitted, :verified])}
  scope :unverified, -> {where expense_status_id: ExpenseStatus.ids_for([:unreported, :unsubmitted, :rejected, :submitted])}

  scope :joins_amount, -> {joins(:amount)}
  scope :sum_amount, -> (currency_code = :INR) {joins_amount.sum(currency_code)}

  scope :joins_card_expenses, -> {only_card_expenses.joins(:card_expense)}
  scope :pluck_card_transaction_id, -> {joins_card_expenses.pluck('card_expense.card_transaction_id')}
  scope :filter_report_status_id, -> (status) {
    filter_status = []
    status = [status] unless status.is_a?(Array)
    if status.include?("1")
      filter_status += ExpenseStatus.ids_for([:unreported, :unsubmitted, :rejected])
    end
    if status.include?("2")
      filter_status << ExpenseStatus.id_for(:submitted)
    end
    if status.include?("3")
      filter_status << ExpenseStatus.id_for(:verified)
    end
    if status.blank?
      filter_status = ExpenseStatus.ids_for([:unreported, :unsubmitted, :rejected, :verified, :submitted])
    end
    where expense_status_id: filter_status
  }
  scope :not_synced_with_quickbooks, -> {where synced_with_quickbooks: [false, nil]}
  scope :synced_with_quickbooks, -> {where synced_with_quickbooks: true}
  scope :with_split_link, -> (split_link) {where split_link: split_link}
  scope :filter_split_link, -> (split_link) {where split_link: split_link}
  scope :includes_export, -> {includes(:category, :user, {report: [:status, policy: [distance_expense_config: [:rate]]]},
                                       :expense_type, {manual_expense: [custom_fields: [:field_configuration, :value]]},
                                       {card_expense: [custom_fields: [:field_configuration]]},
                                       {distance_expense: [{distance: [:physical_unit]}, {maps_distance: [:physical_unit]}, :locations, custom_fields: [:field_configuration]]},
                                       {time_expense: [custom_fields: [:field_configuration]]},
                                       {per_diem_expense: [per_diem: [:configurable, rate: [:currency]], custom_fields: [:field_configuration]]},
                                       {amount: [:currency]}, :expense_status)}
  scope :includes_amount, -> {includes :amount}
  scope :sum_amounts, -> (currency_code = :INR) {includes_amount.sum("amounts.#{currency_code}")}
  scope :includes_tds_amount, -> {includes :tds_amount}
  scope :sum_tds_amounts, -> (currency_code = :INR) do
    amount_ids = pluck(:tds_amount_id)
    Amount.with_id(amount_ids).sum(currency_code)
  end
  scope :sum_reimbursements, -> (currency_code = :INR) {reimbursable.sum_amounts(currency_code) - reimbursable.sum_tds_amounts(currency_code)}
  scope :with_expense_tax_type_id, -> (id) {where expense_tax_type_id: id}
  scope :filter_custom_drop_down_selection, ->(drop_down_item_id) do
    drop_down_selection_ids = FieldDropDownSelection.with_value(drop_down_item_id).pluck(:id)
    configs = CustomField.with_drop_down_selection(drop_down_selection_ids).includes_parent.with_parent_report
    expense_ids = configs.map {|item| item.parent&.id}
    with_id(expense_ids)
  end
  scope :with_spent_from_id, -> (spent_from_id) {
    where spent_from_id: spent_from_id
  }


  scope :user_budget_expenses, -> (from, to) {

    if from.is_a? Date
      from = from
    else
      from = Date.parse(from.to_s) rescue Date.parse("1993-04-13")
    end
    if to.is_a? Date
      to = to
    else
      to = Date.parse(to.to_s) rescue Date.today
    end

    # from = from if from.is_a?(Date) else
    # to = Date.parse(to) rescue Date.today
    where('(expenses.expense_status_id IN (?) AND expenses.report_id IS NOT NULL) OR (expenses.expense_status_id = ? AND expenses.expense_type_id = ?)', [ExpenseStatus.id_for(:unsubmitted), ExpenseStatus.id_for(:submitted), ExpenseStatus.id_for(:verified)], ExpenseStatus.id_for(:unreported), ExpenseType.id_for(:card)).
        where('expenses.date >= ? AND expenses.date <= ?', from, to)
  }

  scope :include_spent_from_calculation, ->{ includes([{amount: [:currency]}], {spent_from: [:user_pocket_type, {balance: [:currency]}, :base_currency]})}

  scope :include_details, -> {includes(
      [
          {amount: [:currency]}, :expense_status,
          :report,
          {user: [{policies: [
          {vehicle_rates: [{rate: [:currency]},
                           :distance_unit]}, :distance_expense_config]}]}, :expense_type, :category,
          {surcharge: [:currency]}, {tds_amount: [:currency]},
          {gst_amount: [:currency]}, :expense_tax_type, :gst_type, :tds_slab,
          {spent_from: [:user_pocket_type, {balance: [:currency]}, :base_currency]}, :receipts, :system_messages,
          :duplicate_expense_mappings,
          {manual_expense: [custom_fields: [{field_configuration: [:field_type, {drop_down_items: [dependent_field_configurations: [:drop_down_items]]}]}, :value]]},
          {card_expense: [custom_fields: [:field_configuration]]},
          {distance_expense: [{custom_fields: [{field_configuration: [:field_type, {drop_down_items: [dependent_field_configurations: [:drop_down_items]]}]}, :value]}, :distance,
                              :maps_distance, :locations, :type, :odometer_reading_receipt_start,
                              :odometer_reading_receipt_end,
                              {vehicle_rate: [{rate: [:currency]}]},
                              :distance_rate, :distance_unit]},
          {time_expense: [custom_fields: [{field_configuration: [:field_type, {drop_down_items: [dependent_field_configurations: [:drop_down_items]]}]}, :value]]},
          {per_diem_expense: [{custom_fields: [{field_configuration: [:field_type, {drop_down_items: [dependent_field_configurations: [:drop_down_items]]}]}, :value]}, :per_diem]},
          :payment
      ]
  )}

  # scope :category_budget_expenses, -> {
  #   where('expenses.category_id = ?')
  # }

  delegate :category_name, to: :category
  delegate :amount_with_currency, to: :amount

  def currency_id
    if self.amount.present?
      return self.amount.currency_id
    else
      return nil
    end
  end

  # this method is to purely show the amount values for the carious expenses
  def amount_value
    case self.expense_type_id
    when ExpenseType.id_for(:manual), ExpenseType.id_for(:card)
      if self.report_id.blank? || self.report.blank?
        return precision_value self.amount.value
      else
        base_currency_code = self.report.base_currency_code
        return precision_value self.amount.send(base_currency_code.to_sym)
      end
    when ExpenseType.id_for(:distance), ExpenseType.id_for(:time), ExpenseType.id_for(:per_diem)
      if self.amount.blank?
        return nil
      else
        if self.report_id.blank?
          return precision_value self.amount.value
        else
          base_currency_code = self.report.base_currency_code
          return precision_value self.amount.send(base_currency_code.to_sym)
        end
      end
    else
      return nil
    end
  end


  def base_amount
    unless expense_type_id == ExpenseType.id_for(:manual) and self.amount.present?
      return self.amount
    end
    currency = report_id.present? ? report.base_currency : amount.currency
    Amount.new(value: amount_value, currency: currency)
  end

  def original_amount
    self.amount
  end

  def conversion_rate
    return nil unless expense_type_id == ExpenseType.id_for(:manual) and self.amount.present? and report_id.present?
    converted_amount = amount_value
    original_amount = original_amount_value
    return nil unless converted_amount.present? and converted_amount > 0 and original_amount.present? and original_amount > 0
    precision_value converted_amount / original_amount
  end

  def converted?
    return false unless expense_type_id == ExpenseType.id_for(:manual) and self.amount.present? and report_id.present?
    if report.base_currency_id != amount.currency_id
      return true
    end
    false
  end

  # this method is to calculate the amount values for the various time/distance/per diem expenses
  def calculate_amount_value(policy = nil)
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      return self.amount.value
    when ExpenseType.id_for(:card)
      return self.amount.value
    when ExpenseType.id_for(:distance)
      if distance_expense.vehicle_rate.blank? and policy.present?
        distance_expense.update(vehicle_rate_id: policy&.vehicle_rates&.first&.id)
      end
      if distance_expense&.distance.present?
        rate = distance_expense.vehicle_rate&.rate&.value # rescue nil
        amount = rate.blank? ? 0 : (self.distance_expense.distance.value * rate)
        return amount
      end
    when ExpenseType.id_for(:time)
      rate = policy.time_expense_config.rate_value # rescue nil
      amount = rate.blank? ? 0 : (self.time_expense.time_object.value * rate)
      return amount
    when ExpenseType.id_for(:per_diem)
      per_diem = self.per_diem_expense.per_diem
      if policy.per_diems.include?(per_diem)
        rate = self.per_diem_expense.per_diem.rate_value # rescue nil
        amount = rate.blank? ? 0 : (self.per_diem_expense.quantity * rate)
        return amount
      else
        return 0
      end
    else
      return 0
    end
  end


  def merchant_name(options = {})
    simple = !!options&.dig(:simple)
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      # this will handle cases for deleted expenses as well.
      merchant = self.manual_expense.merchant rescue nil
      if merchant.nil?
        merchant = ManualExpense.unscoped.find_by(expense_id: self.id).merchant rescue ""
      end
      return merchant
    when ExpenseType.id_for(:card)
      # this will handle cases for deleted expenses as well.
      return "" if self.card_expense.nil?
      return self.card_expense.editable_merchant
    when ExpenseType.id_for(:per_diem)
      # un-scoping here for cases when the per diem gets destroyed
      policy_name = self.per_diem_expense.per_diem&.configurable&.name
      if policy_name.nil?
        policy_name = PerDiem.unscoped.find_by(id: self.per_diem_expense.per_diem_id)&.configurable&.name
      end
      per_diem_name = self.per_diem_expense&.per_diem_name rescue nil
      if per_diem_name.nil?
        per_diem_name = PerDiem.unscoped.find_by(id: self.per_diem_expense.per_diem_id)&.name
      end
      return "#{policy_name} - #{per_diem_name}"
    else
      if self.distance_expense?
        rate = ''
        if distance_expense.vehicle_rate.present?
          rate = simple ? " @ " : " at "
          rate += "#{distance_expense.vehicle_rate.rate.currency.symbol}#{distance_expense.vehicle_rate&.rate&.value} #{distance_expense.vehicle_rate.rate.currency.country_code} per KM"
        end
        return "#{self.distance_expense.distance_value} KM#{rate}"
      elsif self.time_expense?
        rate = ''
        if (not self.report.nil?) and report.policy.time_expense_config.rate_value.present?
          rate = simple ? " @ " : " at "
          rate += "#{report.policy.base_currency.symbol}#{report.policy.time_expense_config.rate_value} #{report.policy.base_currency.country_code} per Hour"
        end
        return "#{self.time_expense.time_object_value} Hours#{rate}"
      end
    end
  end

  def surcharge_value
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      return 0
    when ExpenseType.id_for(:card)
      return self.card_expense.surcharge_amount
    end
  end

  def original_amount_value
    if self.amount.present?
      self.amount.value
    else
      nil
    end
  end

  def report_name
    if report_id
      self.report.name
    end
  end

  def deletable_expense?
    unless self.expense_type_id == ExpenseType.card_expense_id
      return true
    end
    false
  end

  def distance_value
    if self.distance_expense?
      return self.distance_expense.distance_value
    else
      return nil
    end
  end

  def maps_distance_value
    if self.distance_expense?
      return self.distance_expense.maps_distance_value
    else
      return nil
    end
  end

  def distance_rate_value
    if self.distance_expense?
      if self.distance_expense&.vehicle_rate&.rate.present?
        return distance_expense.vehicle_rate.rate.value
      else
        return nil
      end
    else
      return nil
    end
  end

  def time_value
    if self.time_expense?
      return self.time_expense.time_object_value
    else
      return nil
    end
  end


  def time_rate_value
    if self.time_expense?
      if self.report_id.present?
        return self.report.policy.time_expense_config.rate_value
      else
        return nil
      end
    else
      return nil
    end
  end

  def per_diem_quantity_value
    if self.per_diem_expense?
      return self.per_diem_expense.quantity
    else
      return nil
    end
  end

  def per_diem_rate_value
    if self.per_diem_expense?
      # unscoping for cases when the per diem gets destroyed
      rate = self.per_diem_expense.per_diem&.rate_value rescue nil
      if rate.nil?
        rate = PerDiem.unscoped.find_by(id: self.per_diem_expense.per_diem_id).rate_value
      end
      return rate
    else
      return nil
    end
  end

  def per_diem_name
    if self.per_diem_expense?
      # unscoping for cases when the per diem gets destroyed
      policy_name = self.per_diem_expense.per_diem&.configurable&.name
      if policy_name.nil?
        policy_name = PerDiem.unscoped.find_by(id: self.per_diem_expense.per_diem_id)&.configurable&.name
      end
      per_diem_name = self.per_diem_expense&.per_diem_name rescue nil
      if per_diem_name.nil?
        per_diem_name = PerDiem.unscoped.find_by(id: self.per_diem_expense.per_diem_id)&.name
      end
      return "#{policy_name} - #{per_diem_name}"
    else
      return nil
    end
  end

  def custom_fields
    self.sub_expense&.custom_fields
  end

  def custom_field_names
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      return self.manual_expense.custom_field_names
    when ExpenseType.id_for(:distance)
      return self.distance_expense.custom_field_names
    when ExpenseType.id_for(:time)
      return self.time_expense.custom_field_names
    when ExpenseType.id_for(:per_diem)
      return self.per_diem_expense.custom_field_names
    when ExpenseType.id_for(:card)
      return self.card_expense.custom_fields
    else
      return []
    end
  end

  def custom_field_values
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      return self.manual_expense.custom_field_values
    when ExpenseType.id_for(:distance)
      return self.distance_expense.custom_field_values
    when ExpenseType.id_for(:time)
      return self.time_expense.custom_field_values
    when ExpenseType.id_for(:per_diem)
      return self.per_diem_expense.custom_field_values
    when ExpenseType.id_for(:card)
      return self.card_expense.custom_fields
    else
      return []
    end
  end

  def custom_field_value_by_name(name)
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      return self.manual_expense.custom_field_value_by_name(name)
    when ExpenseType.id_for(:distance)
      return self.distance_expense.custom_field_value_by_name(name)
    when ExpenseType.id_for(:time)
      return self.time_expense.custom_field_value_by_name(name)
    when ExpenseType.id_for(:per_diem)
      return self.per_diem_expense.custom_field_value_by_name(name)
    when ExpenseType.id_for(:card)
      return self.card_expense.custom_fields
    else
      return []
    end
  end

  def partially_transcribed
    if self.system_messages.errors.present?
      return true
    end
    false
  end

  # returns the number of receipts attached to this expense
  def receipts_count
    self.receipts.count
  end

  def manual_expense?
    self.expense_type_id == ExpenseType.manual_expense_id
  end

  def card_expense?
    self.expense_type_id == ExpenseType.card_expense_id
  end

  def distance_expense?
    self.expense_type_id == ExpenseType.distance_expense_id
  end

  def time_expense?
    self.expense_type_id == ExpenseType.time_expense_id
  end

  def per_diem_expense?
    self.expense_type_id == ExpenseType.per_diem_expense_id
  end

  def unreported?
    expense_status_id == ExpenseStatus.unreported_id
  end

  def unsubmitted?
    expense_status_id == ExpenseStatus.unsubmitted_id
  end

  def submitted?
    expense_status_id == ExpenseStatus.submitted_id
  end

  def rejected?
    expense_status_id == ExpenseStatus.rejected_id
  end

  def cancellable?
    unless self.expense_status_id == ExpenseStatus.id_for(:unreported)
      return false
    end
    # i.e. check if the expense is a card expense
    unless self.expense_type_id == ExpenseType.id_for(:card)
      return false
    end
    # i.e. if it has already been cancelled
    if self.card_expense.cancelled
      return false
    end
    # i.e. if it is an atm surcharge
    if self.card_expense.atm_surcharge
      return false
    end
    true
  end

  def cancelled?
    unless self.expense_type_id == ExpenseType.id_for(:card)
      return false
    end
    if self.card_expense.cancelled
      return true
    end
    false
  end

  def editable?
    [ExpenseStatus.id_for(:unreported), ExpenseStatus.id_for(:unsubmitted), ExpenseStatus.id_for(:rejected)].include?(self.expense_status_id)
  end

  # method that updates all the currency values for a particular expense - todo - possibly should be moved to an operation
  def update_other_currencies
    unless self.amount.present?
      return
    end
    # calls the respective method in the amounts model to update the currencies
    self.amount.update_currencies(self.date)
  end

  def destroy_other_currencies
    unless self.amount.present?
      return
    end
    # calls the respective method in the amounts model to update the currencies
    self.amount.destroy_currencies
  end

  def currency_symbol
    if self.amount.present?
      self.amount.currency.symbol
    else
      return nil
    end
  end

  def currency_country_code
    if self.amount.present?
      self.amount.currency.country_code
    else
      return nil
    end
  end

  def has_duplicate_expenses?
    filtered_duplicate_expenses.limit_to(1).present?
  end

  def filtered_duplicate_expenses
    if submitted?
      return duplicate_expenses.submitted
    end
    duplicate_expenses
  end

  def can_delete?
    !self.submitted?
  end

  def has_custom_fields?
    !!self.sub_expense&.custom_fields.present?
  end

  def sub_expense
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      self.manual_expense
    when ExpenseType.id_for(:card)
      self.card_expense
    when ExpenseType.id_for(:distance)
      self.distance_expense
    when ExpenseType.id_for(:time)
      self.time_expense
    when ExpenseType.id_for(:per_diem)
      self.per_diem_expense
    end
  end

  def report_status
    case expense_status_id
    when ExpenseStatus.id_for(:unreported), ExpenseStatus.id_for(:unsubmitted), ExpenseStatus.id_for(:rejected)
      'Unreported'
    when ExpenseStatus.id_for(:submitted)
      'Submitted'
    when ExpenseStatus.id_for(:verified)
      'Verified'
    end
  end

  def is_split?
    self.split_link.present?
  end

  def split_count
    return 1 if self.split_link.blank?
    Expense.with_split_link(self.split_link).count
  end

  def incomplete?
    self.sub_expense&.incomplete?
  end

  def has_tds?
    ExpenseTaxType.ids_for(:gst_tds, :tds).include?(expense_tax_type_id)
  end

  def has_gst?
    ExpenseTaxType.ids_for(:gst_tds, :gst).include?(expense_tax_type_id)
  end

  def reimbursable_amount_value
    return 0 unless reimbursable
    return amount&.value.to_f unless has_tds?
    # return amount&.value.to_f unless tds_amount.present?
    return amount.value.to_f unless tds_slab.present?
    tds_amount = tds_slab.tds * amount&.value.to_f / 100
    precision_value(amount&.value.to_f - tds_amount)
  end

  # alias_method :reimbursable_amount, :reimbursable_amount_value

  def reimbursable_amount
    value = reimbursable ? reimbursable_amount_value : 0
    currency_id = amount&.currency_id || Currency.id_for(:INR)
    Amount.new(value: value, currency_id: currency_id)
  end

  def compute_gst_amount
    return unless has_gst? and self.gst_percentage.present?

    gst_amount_value = self.amount.value * self.gst_percentage / 100
    set_gst_amount(gst_amount_value)
  end

  def set_gst_amount(value)
    if value.nil?
      if self.gst_amount.present?
        self.gst_amount.destroy
      end
    else
      if self.gst_amount.present?
        self.gst_amount.value = value
      else
        self.build_gst_amount(value: value, currency_id: Currency.id_for(:INR))
      end
    end
  end

  # Set the reimbursable amount if "reimbursable" flag is set and the tax type has TDS included
  def compute_tds_amount
    return unless has_tds?

    tds_amount_value = nil
    tax_amount = 0
    if ExpenseTaxType.id_for(:gst_tds) == expense_tax_type_id and self.gst_percentage.present? and self.gst_percentage > 0
      tax_amount = self.amount.value * self.gst_percentage / 100
    end
    tds_percentage = self.tds_slab&.tds
    if tds_percentage.present?
      tds_amount_value = (self.amount.value - tax_amount) * (tds_percentage) / 100
    end

    set_tds_amount(tds_amount_value)
  end

  def set_tds_amount(value)
    if value.nil?
      if self.tds_amount.present?
        self.tds_amount.destroy
      end
    else
      if self.tds_amount.present?
        self.tds_amount.value = value
      else
        self.build_tds_amount(value: value, currency_id: Currency.id_for(:INR))
      end
    end
  end

  def usage_days
    return nil if usage_date_type.blank? or usage_date_type == 'none'
    days = (usage_date_start.to_date..usage_date_end.to_date).to_a
    if (usage_date_type == 'hotel') and usage_date_end.to_date == usage_date_start.to_date
      days.pop
    end
    days
  end

  # def from_cash_on_hand
  #   if self.spent_from.present? and not (self.spent_from.paid_by_company? or self.spent_from.reimbursement?)
  #     return true
  #   end
  #   false
  # end

  def check_spent_from?
    return false if reimbursable
    return false if card?
    true
  end

  private

  # cannot add an expense with future date
  def no_future_date
    if date.present? and date > DateUtils.local_date
      errors.add(:date, 'cannot be in the future!')
    end
  end

  def at_least_one_type
    case self.expense_type_id
    when ExpenseType.id_for(:manual)
      if self.manual_expense.nil?
        errors.add(:expense, "needs to have an associated manual expense")
      end
    when ExpenseType.id_for(:card)
      if self.card_expense.nil?
        errors.add(:expense, "needs to have an associated card expense")
      end
    when ExpenseType.distance_expense_id
      if self.distance_expense.blank?
        errors.add(:expense, "needs to have an associated distance expense")
      end
    when ExpenseType.time_expense_id
      if self.time_expense.blank?
        errors.add(:expense, "needs to have an associated time expense")
      end
    when ExpenseType.per_diem_expense_id
      if self.per_diem_expense.blank?
        errors.add(:expense, "needs to have an associated per diem expense")
      end
    else
      errors.add(:expense, "type is invalid")
    end
  end


  def valid_expense_type
    case expense_type_id
    when ExpenseType.manual_expense_id
      if self.manual_expense.blank?
        errors.add(:merchant, "can't be blank")
      end
    when ExpenseType.card_expense_id
      if self.card_expense.blank?
        errors.add(:card, 'expense details not found')
      end
    when ExpenseType.distance_expense_id
      if self.distance_expense.blank?
        errors.add(:distance, "expense cannot be blank")
      end
    when ExpenseType.time_expense_id
      if self.time_expense.blank?
        errors.add(:time, "expense cannot be blank")
      end
    when ExpenseType.per_diem_expense_id
      if self.per_diem_expense.blank?
        errors.add(:per_diem, "expense cannot be blank")
      end
    else
      errors.add(:expense, 'type not allowed')
    end
  end

  def valid_amount_value
    if self.manual_expense? || self.card_expense?
      if self.amount.blank? or self.amount.value.blank?
        errors.add(:amount, "can't be blank")
      elsif self.amount.value < 0
        errors.add(:amount, "can't be less than or equal to 0")
      end
    end
  end

  def validate_usage_dates
    if (usage_date_start.present? or usage_date_end.present?) and usage_date_type.blank?
      errors.add :usage_date_type, 'has not been defined'
      return
    end
    if usage_date_type.present? and usage_date_start.blank?
      errors.add :usage_dates, 'have not been defined'
      return
    end
  end


  def budget_trail_entry
    # if this expense was somehow removed from a report, or the report was updated in anyway, we update its entry in the BudgetTrail model
    if ReportStatus.ids_for([:approved, :settled, :settlement_confirmed, :closed]).include?(self.report&.report_status_id)
      BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.save_trail(self)
    else
      BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.destroy_trail(self)
    end
  end

  def budget_trail_destroy
    BudgetsCalculator::Calculate::ExpenseBudgetsProcessor.new.destroy_trail(self)
  end
end
