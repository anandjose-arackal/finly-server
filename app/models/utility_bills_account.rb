# == Schema Information
#
# Table name: utility_bills_accounts
#
#  id         :bigint           not null, primary key
#  balance_id :integer
#  company_id :integer
#  enabled    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

class UtilityBillsAccount < ApplicationRecord

  include Accountable

  belongs_to :company
  belongs_to :balance, class_name: "Amount"

  delegate :balance_value, to: :balance

  accepts_nested_attributes_for :balance

  has_many :initiating_payments, as: :initiating_account
  has_many :initiating_payment_trails, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account, class_name: "Payment"
  has_many :receiving_payment_trails, as: :receiving_account
  has_many :finly_transactions, as: :finly_account
  has_many :virtual_bank_accounts, as: :receiving_account

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    PaymentOrder.with_company_id(self.company_id).with_initiating_account_type("UtilityBillsAccount").without_id(excluded_payment_order_id).scheduled.joins(:amount_requested).sum(:value)
  end

  scope :with_company_id, -> (company_id) {
    where company_id: company_id
  }

  def va_config
    {
        enabled: true,
        purpose_id: VirtualAccountPurpose.id_for(:corporate_account_reload),
        company: company,
        application: :em
    }
  end

  scope :sum_balances, -> {
    joins(:balance).sum(:value)
  }
end
