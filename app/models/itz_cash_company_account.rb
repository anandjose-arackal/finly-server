# == Schema Information
#
# Table name: itz_cash_company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  wallet_balance_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  balance_id        :integer
#

class ItzCashCompanyAccount < ApplicationRecord
  include Accountable
  belongs_to :company, optional: true
  belongs_to :balance, optional: true, class_name: "Amount"
  belongs_to :wallet_balance, optional: true, class_name: "Amount"

  delegate :balance_value, to: :balance

  has_many :initiating_payments, as: :initiating_account
  has_many :initiating_payment_trails, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account
  has_many :receiving_payment_trails, as: :receiving_account
  has_many :finly_transactions, as: :finly_account
  has_many :auto_reload_configs, as: :source_account

  accepts_nested_attributes_for :balance
  accepts_nested_attributes_for :wallet_balance

  def total_wallet_balance
    user_ids = self.company.users.pluck(:id)
    UserWallet.where(user_id: user_ids).joins(:balance).sum(:value)
  end

  def blocked_amount_for_pending_payments
    PaymentOrder.with_company_id(self.company_id).with_initiating_account_type("ItzCashCompanyAccount").scheduled.joins(:amount_requested).sum(:value)
  end

end
