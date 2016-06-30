class Expense < ActiveRecord::Base
  belongs_to :amount
  belongs_to :expense_status
  belongs_to :user
  belongs_to :expense_type

  has_one :manual_expense

  accepts_nested_attributes_for :amount, :expense_status, :expense_type
end
