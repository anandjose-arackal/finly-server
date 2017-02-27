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
#





  

include MathUtil

class Expense < ActiveRecord::Base
  include SoftDeletable

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

  accepts_nested_attributes_for :amount
  accepts_nested_attributes_for :manual_expense
  accepts_nested_attributes_for :card_expense
  accepts_nested_attributes_for :receipts


  # delegating to associated classes the dependent attribute calls
  delegate :amount_value, :currency, to: :amount
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


  scope :with_amount, -> { joins :amount }
  scope :with_report, ->(report_id) { where report_id: report_id }
  scope :with_user, ->(user_id) { where user_id: user_id }
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

  scope :filter_merchant, -> (merchant_name) {
    expense_ids = ManualExpense.where('merchant like ?', "%#{merchant_name}%").pluck(:expense_id)
    expense_ids += CardExpense.where('editable_merchant like ?', "%#{merchant_name}%").pluck(:expense_id)

    where(id: expense_ids)
  }

  # scope :filter_merchant, -> (merchant_name) {
  #   joins(:manual_expense, :card_expense).select('expenses.*').where('lower(merchant) like ? OR lower(editable_merchant) like ?', "%#{merchant_name}%", "%#{merchant_name}%")
  # }

  scope :filter_status_id, -> (status_id) { where expense_status_id: status_id }
  scope :filter_search, -> (value) do
    expense_ids = ManualExpense.where('merchant like ?', "%#{value}%").pluck(:expense_id)
    expense_ids += CardExpense.where('editable_merchant like ?', "%#{value}%").pluck(:expense_id)

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

  scope :only_card_expenses, -> { where(expense_type_id: 2) }
  scope :only_manual_expenses, -> { where(expense_type_id: 1) }

  scope :with_id, ->(ids) { where id: ids }
  scope :with_date, ->(dates) { where date: dates }
  scope :with_amount, -> { joins(:amount).select('expenses.*, amounts.*') }
  scope :unreported, -> { where expense_status_id: [ExpenseStatus.unreported_id, ExpenseStatus.rejected_id] }
  scope :submitted, -> { where expense_status_id: ExpenseStatus.submitted_id }
  scope :admin_viewable, -> { where expense_status_id: [ExpenseStatus.submitted_id, ExpenseStatus.rejected_id] }
  scope :sort_date_desc, -> { order 'date DESC' }
  scope :sort_date_asc, -> { order 'date ASC' }
  scope :with_category, ->(category_id) { where category_id: category_id }
  scope :include_manual_expense, -> { joins :manual_expense }
  scope :filter_user_id, ->(id) { where user_id: id }

  delegate :category_name, to: :category


  def merchant_name
    case self.expense_type_id
      when 1
        return self.manual_expense.merchant
      when 2
        # todo - temporary
        return "" if self.card_expense.nil?
        return self.card_expense.editable_merchant
      else
        # do nothing
    end
  end

  def surcharge_value
    case self.expense_type_id
      when 1
        return 0
      when 2
        return self.card_expense.surcharge_amount
    end
  end

  def report_name
    if report_id
      self.report.name
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
      else
        errors.add(:expense, 'type not allowed')
    end
  end

  def valid_amount_value
    if self.amount.blank? or self.amount.value.blank?
      errors.add(:amount, "can't be blank")
    elsif self.amount.value <= 0
      errors.add(:amount, "can't be less than or equal to 0")
    end
  end

end
