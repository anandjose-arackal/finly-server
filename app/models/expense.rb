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

  validates
end
