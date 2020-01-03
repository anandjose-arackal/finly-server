# == Schema Information
#
# Table name: kotak_bank_company_accounts
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  balance_id :integer
#  enabled    :boolean          default(FALSE)
#  deleted_at :datetime
#

class KotakBankCompanyAccount < ApplicationRecord

  belongs_to :company
  belongs_to :balance, class_name: "Amount", optional: true

  has_many :initiating_payments, as: :initiating_account
  has_many :initiating_payment_trails, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account
  has_many :receiving_payment_trails, as: :receiving_account
  has_many :finly_transactions, as: :finly_account

  accepts_nested_attributes_for :balance

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    PaymentOrder.with_company_id(self.company_id).with_initiating_account_type("KotakBankCompanyAccount").without_id(excluded_payment_order_id).scheduled.joins(:amount_requested).sum(:value)
  end

  scope :with_company_id, -> (company_id) {
    where company_id: company_id
  }

  scope :sum_balances, -> {
    joins(:balance).sum(:value)
  }

  delegate :balance_value, to: :balance
end
