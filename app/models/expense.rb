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
#

class Expense < ActiveRecord::Base
  belongs_to :amount
  belongs_to :expense_status
  belongs_to :user
  belongs_to :expense_type
  belongs_to :category
  belongs_to :report
  belongs_to :rejecting_manager, class_name: 'User'

  has_many :receipts, as: :parent

  has_one :manual_expense, dependent: :destroy

  accepts_nested_attributes_for :amount, :manual_expense
  accepts_nested_attributes_for :receipts

  # delegating to associated classes the dependent attribute calls
  delegate :amount_value, :currency, to: :amount
  delegate :expense_type, to: :expense_type
  delegate :expense_status, to: :expense_status
  delegate :merchant_name, to: :manual_expense
  delegate :user_name, to: :user


  validates :amount_id, presence: true
  validates :date, presence: true
  validates :category_id, presence: true
  validates :expense_type_id, presence: true
  validates :user_id, presence: true
  validate :no_future_date
  validate :created_by
  validate :report_status


  # i.e. an expense associated with a report can't be destroyed
  before_destroy {
    if self.report_id
      errors.add(:expense, "associated with a report can't be destroyed.")
    end
  }

  # scopes for the filters
  scope :filter_amount, -> (type, value) do
    case type
      when 'lteq'
        joins(:amount).select('expenses.*').where('value <= ?', value)
      when 'gteq'
        joins(:amount).select('expenses.*').where('value >= ?', value)
      when 'eq'
        joins(:amount).select('expenses.*').where('value = ?', value)
      else
        # do nothing
    end
  end
  scope :filter_date, ->(date_from = nil, date_to = nil) do

    unless date_from.blank? && date_to.blank?
      type_val = :date
      date_from = "1990-01-01" if date_from.blank?
      date_to = Date.today if date_to.blank?
      expenses = arel_table
      where(expenses[type_val].gteq(date_from).and(expenses[type_val].lteq(date_to)))
    end
  end
  scope :filter_category_id, -> (category_id) {where category_id: category_id}
  scope :filter_merchant, -> (merchant_name) do
    joins(:manual_expense).select('expenses.*').where('merchant like ?', "%#{merchant_name}%")
  end
  scope :filter_status_id, -> (status_id) {where expense_status_id: status_id}
  scope :filter_search, -> (value) do
    joins(:manual_expense).joins(:amount).select('expenses.*').where('merchant_name like ? OR note like ?', "%#{value}%")
  end

  # todo - revisit this once you figure out how to filter based on presence of children
  scope :filter_receipt, -> (value) do
    case value
      when 'present'
        joins(:receipts).select('expenses.*').where('')
      when 'nil'
        joins(:receipts).select('expenses.*')
    end
  end


  scope :with_id, ->(ids) { where id: ids }
  scope :with_amount, -> { joins(:amount).select('expenses.*, amounts.*') }
  scope :unreported, -> { where expense_status_id: [ExpenseStatus.unreported_id, ExpenseStatus.rejected_id] }
  scope :sort_date_desc, -> { order 'date DESC' }
  scope :sort_date_asc, -> { order 'date ASC' }
  scope :with_category, ->(category_id) { where category_id: category_id }

  delegate :category_name, to: :category




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

  # only employees can create an expense
  def created_by
    unless self.user.employee?
      errors.add(:expense, 'can only be created by employees')
    end
  end

  # cannot add an expense with future date
  def no_future_date
    if date.present? and date > Date.today
      errors.add(:date, "cannot be in the future!")
    end
  end

  # ensuring the report is either open or retracted before allowing editing of expense
  def report_status
    if self.report_id
      report = self.report
      unless report.open? or report.retracted?
        errors.add(:report, ' cannot be edited in this state.')
      end
    end
  end


end
