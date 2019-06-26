# == Schema Information
#
# Table name: icici_bank_company_accounts
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#  balance_id :integer
#

class IciciBankCompanyAccount < ApplicationRecord
  belongs_to :company
  belongs_to :balance, class_name: "Amount"

  has_many :initiating_payments, as: :initiating_account
  has_many :initiating_payment_trails, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account
  has_many :receiving_payment_trails, as: :receiving_account
  has_many :finly_transactions, as: :finly_account

  accepts_nested_attributes_for :balance

  def blocked_amount_for_pending_payments(excluded_payment_order_id = nil)
    PaymentOrder.with_company_id(self.company_id).with_initiating_account_type("IciciBankCompanyAccount").without_id(excluded_payment_order_id).scheduled.joins(:amount_requested).sum(:value)
  end

  scope :with_company_id, -> (company_id) {
    where company_id: company_id
  }

  scope :sum_balances, -> {
    joins(:balance).sum(:value)
  }

end