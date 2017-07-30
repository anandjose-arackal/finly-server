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

class YesBankCompanyAccount < ActiveRecord::Base
  belongs_to :company
  belongs_to :balance, class_name: "Amount"
  belongs_to :wallet_balance, class_name: "Amount"

  delegate :balance_value, to: :balance

  has_many :initiating_payments, as: :initiating_account
  has_many :initiating_payment_trails, as: :initiating_account
  has_many :receiving_payments, as: :receiving_account
  has_many :receiving_payment_trails, as: :receiving_account

  accepts_nested_attributes_for :balance
  accepts_nested_attributes_for :wallet_balance
end
