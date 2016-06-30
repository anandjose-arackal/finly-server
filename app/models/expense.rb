class Expense < ActiveRecord::Base
  belongs_to :amount
  belongs_to :expense_status
  belongs_to :user
  belongs_to :expense_type

  has_one :manual_expense, dependent: :destroy

  accepts_nested_attributes_for :amount, :expense_status, :expense_type, :manual_expense

  delegate :amount_value, :currency, to: :amount
  delegate :expense_type, to: :expense_type
  delegate :expense_status, to: :expense_status
  delegate :merchant_name, to: :manual_expense

  # to ensure two expenses don't have the same foreign key
  validates :amount_id, uniqueness: true
  validate :no_future_date

  # cannot add an expense with future date
  def no_future_date
    if date > Date.today
      errors.add(:date, "cannot be in the futute!")
    end
  end

end
