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

class CashOnHand < ApplicationRecord
  include Accountable
  belongs_to :user, optional: true
  belongs_to :balance, optional: true, class_name: "Amount"

  has_many :initiating_payments, as: :initiating_account, class_name: "Payment"
  has_many :receiving_payments, as: :receiving_account, class_name: "Payment"
  has_many :finly_transactions, as: :finly_account

  accepts_nested_attributes_for :balance

  scope :joins_balance, -> { joins :balance }
  scope :having_balance_value, -> { joins_balance.where('value > 0') }
  scope :with_user, ->(id) { where user_id: id }
  scope :sum_balance, -> { joins_balance.sum('amounts.value') }

  delegate :balance_value, to: :balance

  def credit_funds(amount)
    balance = self.balance_value
    self.balance.update(value: (balance + amount))
  end

  def debit_funds(amount)
    balance = self.balance_value
    self.balance.update(value: (balance - amount))
  end

  def va_config
    {
        enabled: true,
        purpose_id: VirtualAccountPurpose.id_for(:cash_on_hand_return),
        company: user.company,
        application: :em
    }
  end

end
