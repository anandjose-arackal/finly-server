# == Schema Information
#
# Table name: expenses
#
#  id                   :integer          not null, primary key
#  amount_id            :integer
#  expense_status_id    :integer
#  note                 :text(65535)
#  date                 :date
#  user_id              :integer
#  expense_type_id      :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  manager_memo         :text(65535)
#  rejecting_manager_id :integer
#  report_id            :integer
#  category_id          :integer
#  is_deleted           :boolean          default(FALSE), not null
#  transcribed          :boolean          default(FALSE)
#  personal             :boolean          default(FALSE)
#  reimbursable         :boolean          default(TRUE)
#














class Expense < ActiveRecord::Base
  include SoftDeletable
  include MathUtil

  belongs_to :amount
  belongs_to :expense_status
  belongs_to :user
  belongs_to :expense_type
  belongs_to :category
  belongs_to :report
  belongs_to :rejecting_manager, class_name: 'User'
  belongs_to :surcharge, class_name: 'Amount'

  has_many :receipts, as: :parent

  has_one :manual_expense, dependent: :destroy
  has_one :card_expense, dependent: :destroy
  has_one :distance_expense, dependent: :destroy
  has_one :time_expense, dependent: :destroy
  has_one :per_diem_expense, dependent: :destroy

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :manual_expense
  accepts_nested_attributes_for :card_expense
  accepts_nested_attributes_for :receipts
  accepts_nested_attributes_for :distance_expense
  accepts_nested_attributes_for :time_expense
  accepts_nested_attributes_for :per_diem_expense

  # delegating to associated classes the dependent attribute calls
  # delegate :amount_value, :currency, to: :amount
  delegate :surcharge_value, to: :card_expense
  delegate :expense_type_name, to: :expense_type
  delegate :expense_status_name, to: :expense_status
  delegate :user_name, to: :user

  validates :date, presence: true
  validates :category_id, presence: true
  validates :expense_type_id, presence: true
  validates :user_id, presence: true
  validate :no_future_date
  # validate :report_status
  validate :valid_expense_type
  validate :valid_amount_value
  validate :at_least_one_type

  # i.e. an expense associated with a report can't be destroyed
  before_destroy do
    errors.add(:expense, "associated with a report can't be destroyed.") if self.report_id

    self.receipts.update_all(parent_id: nil, parent_type: nil) if self.receipts.present?
  end

  before_save do
    if self.expense_status_id.blank?
      if self.report_id.blank?
        self.expense_status_id = ExpenseStatus.unreported_id
      else
        self.expense_status_id = ExpenseStatus.unsubmitted_id
      end
    end
  end

  default_scope { order('expenses.created_at DESC') }

  scope :with_id, -> (ids) {where id: ids}

  scope :non_personal, -> {where(personal: false)}
  scope :personal, -> {where personal: true}

  scope :non_cancelled, -> {
    ids = pluck(:id)
    card_expenses = CardExpense.with_expense_id(ids)
    cancelled_expense_ids = card_expenses.where('cancelled IS true').pluck(:expense_id)
    non_cancelled_ids = ids - cancelled_expense_ids
    self.with_id(non_cancelled_ids)
  }

  scope :include_cancelled, -> {}
  scope :include_personal, -> {}

  scope :with_amount, -> { joins :amount }
  scope :with_report, ->(report_id) { where report_id: report_id }
  scope :with_report_id, ->(report_id) { where report_id: report_id }
  scope :with_user, ->(user_id) { where user_id: user_id }
  scope :with_user_id, ->(user_id) { where user_id: user_id }
  # scope :with_user_for_admin, ->(user_ids) { where('user_id IN (?) AND expense_type_id = ? AND expense_status_id = ?', user_ids, ExpenseType.card_expense_id, ExpenseStatus.submitted_id).uniq }
  scope :filter_expense_type_id, ->(type_id) { where expense_type_id: type_id }

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
    order.upcase! if order
    order("#{sort_by} #{order}") # sort_by: created_at, date etc. order: asc/desc
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
  scope :filter_category_id, -> (category_id) { where category_id: category_id }

  scope :filter_merchant, -> (merchant_name) do
    expense_ids = ManualExpense.where('merchant like ?', "%#{merchant_name}%").pluck(:expense_id)
    expense_ids += CardExpense.where('editable_merchant like ?', "%#{merchant_name}%").pluck(:expense_id)
    expense_ids += PerDiemExpense.joins(:per_diem).where('per_diems.name LIKE ?', "%#{merchant_name}%").pluck(:expense_id)

    where(id: expense_ids)
  end

  # scope :filter_merchant, -> (merchant_name) {
  #   joins(:manual_expense, :card_expense).select('expenses.*').where('lower(merchant) like ? OR lower(editable_merchant) like ?', "%#{merchant_name}%", "%#{merchant_name}%")
  # }

  scope :filter_status_id, -> (status_id) { where expense_status_id: status_id }
  scope :filter_search, -> (value) do
    expense_ids = ManualExpense.where('merchant like ?', "%#{value}%").pluck(:expense_id)
    expense_ids += CardExpense.where('editable_merchant like ?', "%#{value}%").pluck(:expense_id)
    expense_ids += PerDiemExpense.joins(:per_diem).where('per_diems.name LIKE ?', "%#{query}%").pluck(:expense_id)

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

  scope :manual, -> { joins(:manual_expense) }
  scope :card, -> { joins(:card_expense) }

  scope :only_card_expenses, -> { where(expense_type_id: ExpenseType.id_for(:card)) }
  scope :only_manual_expenses, -> { where(expense_type_id: ExpenseType.id_for(:manual)) }
  scope :only_distance_expenses, -> { where(expense_type_id: ExpenseType.id_for(:distance)) }
  scope :only_time_expenses, -> { where(expense_type_id: ExpenseType.id_for(:time)) }
  scope :only_per_diem_expenses, -> { where(expense_type_id: ExpenseType.id_for(:per_diem)) }
  scope :only_reimbursable_expenses, -> {where(expense_type_id: [ExpenseType.id_for(:manual),
                                                                 ExpenseType.id_for(:distance),
                                                                 ExpenseType.id_for(:time),
                                                                 ExpenseType.id_for(:per_diem)])}

  scope :with_id, ->(ids) { where id: ids }
  scope :with_date, ->(dates) { where date: dates }
  scope :with_date_range, -> (start_date, end_date) {where('date >= ? AND date <= ?', start_date, end_date)}
  scope :with_amount, -> { joins(:amount).select('expenses.*, amounts.*') }
  scope :unreported_and_rejected, -> { where expense_status_id: [ExpenseStatus.unreported_id, ExpenseStatus.rejected_id] }
  scope :submitted, -> { where expense_status_id: ExpenseStatus.submitted_id }
  scope :unreported, -> {where expense_status_id: ExpenseStatus.unreported_id}
  scope :rejected, -> {where expense_status_id: ExpenseStatus.rejected_id}
  scope :unsubmitted, -> {where expense_status_id: ExpenseStatus.unsubmitted_id}
  scope :admin_viewable, -> { where expense_status_id: [ExpenseStatus.id_for(:unsubmitted), ExpenseStatus.id_for(:rejected), ExpenseStatus.id_for(:unreported)] }
  scope :sort_date_desc, -> { order 'date DESC' }
  scope :sort_date_asc, -> { order 'date ASC' }
  scope :with_category, ->(category_id) { where category_id: category_id }
  scope :include_manual_expense, -> { joins :manual_expense }
  scope :filter_user_id, ->(id) { where user_id: id }

  scope :transcribed, -> {where transcribed: true}
  scope :untranscribed, -> {where transcribed: false}

  scope :verified, -> {where expense_status_id: ExpenseStatus.submitted_id}
  scope :unverified, -> {where expense_status_id: [ExpenseStatus.unsubmitted_id, ExpenseStatus.unreported_id, ExpenseStatus.rejected_id]}

  delegate :category_name, to: :category


  # this method is to purely show the amount values for the carious expenses
  def amount_value
    case self.expense_type_id
      when ExpenseType.id_for(:manual), ExpenseType.id_for(:card)
        return precision_value self.amount.value
      when ExpenseType.id_for(:distance), ExpenseType.id_for(:time), ExpenseType.id_for(:per_diem)
        if self.amount.blank?
          return nil
        else
          return precision_value self.amount.value
        end
      else
        return nil
    end
  end


  # this method is to calculate the amount values for the various time/distance/per diem expenses
  def calculate_amount_value(policy)
    case self.expense_type_id
      when ExpenseType.id_for(:manual)
        return self.amount.value
      when ExpenseType.id_for(:card)
        return self.amount.value
      when ExpenseType.id_for(:distance)
        if policy.blank?
          rate = self.user.company.distance_expense_config.rate rescue nil
          amount = rate.blank? ? 0 : (self.distance_expense.distance.value * rate)
          return amount
        else
          rate = policy.distance_expense_config.rate rescue nil
          amount = rate.blank? ? 0 : (self.distance_expense.distance.value * rate)
          return amount
        end
      when ExpenseType.id_for(:time)
        if policy.blank?
          rate = self.user.company.time_expense_config.rate rescue nil
          amount = rate.blank? ? 0 : (self.time_expense.time_object.value * rate)
          return amount
        else
          rate = policy.time_expense_config.rate rescue nil
          amount = rate.blank? ? 0 : (self.time_expense.time_object.value * rate)
          return amount
        end
      when ExpenseType.id_for(:per_diem)
        per_diem = self.per_diem_expense.per_diem
        if policy.blank? || policy.is_a?(Company)
          if user.company.per_diems.include?(per_diem)
            rate = self.per_diem_expense.per_diem.rate_value rescue nil
            amount = rate.blank? ? 0 : (self.per_diem_expense.quantity * rate)
            return amount
          else
            return 0
          end
        else
          if policy.per_diems.include?(per_diem)
            rate = self.per_diem_expense.per_diem.rate_value rescue nil
            amount = rate.blank? ? 0 : (self.per_diem_expense.quantity * rate)
            return amount
          else
            return 0
          end
        end
      else
        return 0
    end
  end


  def merchant_name
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
        return "#{self.per_diem_expense.per_diem.configurable.name} - #{self.per_diem_expense.per_diem_name}"
      else
        if self.report.nil?
          return "- -"
        else
          parent = report.policy
          parent = self.user.company if parent.nil?
          if self.distance_expense?
            return "#{self.distance_expense.distance_value} KM @ ₹#{parent.distance_expense_config.rate_per_km} per KM"
          elsif self.time_expense?
            return "#{self.time_expense.time_object_value} Hours @ ₹#{parent.time_expense_config.rate_per_hour} per Hour"
          end
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

  def distance_rate_value
    if self.distance_expense?
      if self.report_id.present?
        report = self.report
        if report.policy
          return report.policy.distance_expense_config.rate_per_km
        else
          return report.user.company.distance_expense_config.rate_per_km
        end
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
        report = self.report
        if report.policy
          return report.policy.time_expense_config.rate_per_hour
        else
          return report.user.company.time_expense_config.rate_per_hour
        end
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
      return self.per_diem_expense.per_diem.rate_value
    else
      return nil
    end
  end

  def per_diem_name
    if self.per_diem_expense?
      return "#{self.per_diem_expense.per_diem.configurable.name} - #{self.per_diem_expense.per_diem_name}"
    else
      return nil
    end
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
    true
  end

  def cancelled?
    unless self.expense_type_id == ExpenseType.id_for(:card)
      return false
    end
    if self.card_expense.cancelled
      return false
    end
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
      elsif self.amount.value <= 0
        errors.add(:amount, "can't be less than or equal to 0")
      end
    end
  end

end
