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

  accepts_nested_attributes_for :amount, :expense_status, :expense_type, :manual_expense

  # delegating to associated classes the dependent attribute calls
  delegate :amount_value, :currency, to: :amount
  delegate :expense_type, to: :expense_type
  delegate :expense_status, to: :expense_status
  delegate :merchant_name, to: :manual_expense

  scope :with_id, ->(ids) { where id: ids }
  scope :with_amount, -> { joins(:amount).select('expenses.*, amounts.*') }
  scope :unreported, -> { where expense_status_id: [ExpenseStatus.unreported_id, ExpenseStatus.rejected_id] }
  scope :sort_latest_first, -> { order 'date DESC' }

  delegate :category_name, to: :category


  # validates :amount_id, uniqueness: true
  validate :no_future_date


  # returns the number of receipts attached to this expense
  def receipts_count
    self.receipts.count
  end

  # cannot add an expense with future date
  def no_future_date
    if date.present? and date > Date.today
      errors.add(:date, "cannot be in the future!")
    end
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

end
