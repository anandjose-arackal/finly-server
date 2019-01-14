# == Schema Information
#
# Table name: vendor_payment_wallets
#
#  id         :integer          not null, primary key
#  balance_id :integer
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VendorPaymentWallet < ApplicationRecord
  include Accountable
  belongs_to :user, optional: true
  belongs_to :balance, optional: true, class_name: "Amount"

  validates :user, presence: true
  validates :balance, presence: true

  has_many :initiating_payments, as: :initiating_account, class_name: "Payment"
  has_many :receiving_payments, as: :receiving_account, class_name: "Payment"
  has_many :finly_transactions, as: :finly_account
  has_many :virtual_bank_accounts, as: :receiving_account

  accepts_nested_attributes_for :balance

  scope :joins_balance, -> { joins :balance }

  scope :having_balance_value, -> { joins_balance.where('value > 0') }
  scope :with_user, ->(id) { where user_id: id }
  scope :sum_balance, -> { joins_balance.sum('amounts.value') }
  scope :sum_balances, -> { sum_balance }

  delegate :balance_value, to: :balance

  def add_funds(amount)
    if amount.blank? or amount.to_d <= 0
      errors.add(:amount, 'cannot be less than or equal to 0')
      return false
    end
    new_balance = amount.to_d + self.balance_value
    unless self.balance.update_attribute(:value, new_balance)
      @errors.merge!(self.balance.instance_variable_get(:@errors))
      return false
    end
    true
  end

  def subtract_funds(amount)
    if amount.blank? or amount.to_d <= 0
      errors.add(:amount, 'cannot be less than or equal to 0')
      return false
    end
    if amount.to_d > self.balance_value
      errors.add(:amount, 'cannot be greater than the remaining balance in the wallet')
      return false
    end
    new_balance = self.balance_value - amount.to_d
    unless self.balance.update_attribute(:value, new_balance)
      @errors.merge!(self.balance.instance_variable_get(:@errors))
      return false
    end
    true
  end

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    initiating_account = self.user.bank_wallet
    payment_ids = PaymentOrder.find_by(id: excluded_payment_order_id)&.payments&.pluck(:id)
    Payment.scheduled.with_initiating_account_type("VendorPaymentWallet").with_initiating_account_id(initiating_account.id).without_id(payment_ids).joins(:amount).sum(:value)
    # PaymentOrder.with_company_id(initiating_user.company_id).with_initiating_account_type("VendorPaymentWallet").with_initiating_user_id(initiating_user.id).scheduled.joins(:amount_requested).sum(:value)
  end

  def va_config
    {
        enabled: true,
        purpose_id: VirtualAccountPurpose.id_for(:finly_money_reload),
        company: user.company,
        application: :em
    }
  end

end
