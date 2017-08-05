# == Schema Information
#
# Table name: cash_on_hands
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  balance_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CashOnHand < ActiveRecord::Base
  belongs_to :user
  belongs_to :balance, class_name: "Amount"

  has_many :payments, as: :initiating_account
  has_many :payments, as: :receiving_account

  accepts_nested_attributes_for :balance

  delegate :balance_value, to: :balance

  def credit_funds(amount)
    balance = self.balance_value
    self.balance.update(value: (balance + amount))
  end

  def debit_funds(amount)
    balance = self.balance_value
    self.balance.update(value: (balance - amount))
  end
end
