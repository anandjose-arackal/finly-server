# == Schema Information
#
# Table name: expenses
#
#  id                :integer          not null, primary key
#  amount_id         :integer
#  expense_status_id :integer
#  note              :text(65535)
#  date              :datetime
#  user_id           :integer
#  expense_type_id   :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  manager_memo      :string(255)
#  category_id       :integer
#

class Expense < ActiveRecord::Base
  belongs_to :amount
  belongs_to :expense_status
  belongs_to :user
  belongs_to :expense_type
  belongs_to :category

  has_many :receipts, as: :parent

  has_one :manual_expense, dependent: :destroy

  accepts_nested_attributes_for :amount, :expense_status, :expense_type, :manual_expense

  # delegating to associated classes the dependent attribute calls
  delegate :amount_value, :currency, to: :amount
  delegate :expense_type, to: :expense_type
  delegate :expense_status, to: :expense_status
  delegate :merchant_name, to: :manual_expense

  delegate :category_name, to: :category

  delegate :receipt_file_name, to: :receipt

  # validates :amount_id, uniqueness: true
  validate :no_future_date

  # cannot add an expense with future date
  def no_future_date
    if date > Date.today
      errors.add(:date, "cannot be in the futute!")
    end
  end

end
