# == Schema Information
#
# Table name: yes_bank_company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  wallet_balance_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  balance_id        :integer
#

class YesBankCompanyAccount < ApplicationRecord
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
  has_many :virtual_bank_accounts, as: :receiving_account

  accepts_nested_attributes_for :balance
  accepts_nested_attributes_for :wallet_balance

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    PaymentOrder.with_company_id(self.company_id).with_initiating_account_type("YesBankCompanyAccount").without_id(excluded_payment_order_id).scheduled.joins(:amount_requested).sum(:value)
  end

  def va_config
    {
        enabled: true,
        purpose_id: VirtualAccountPurpose.id_for(:corporate_account_reload),
        company: company,
        application: :em
    }
  end

end
