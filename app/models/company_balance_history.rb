# == Schema Information
#
# Table name: company_balance_histories
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  neft_transfer_id          :integer
#  company_balance_id        :integer
#  company_withdrawal_id     :integer
#  company_load_id           :integer
#  card_load_id              :integer
#  card_withdrawal_id        :integer
#  card_balance_id           :integer
#  card_expenses_id          :integer
#  wallet_balance_id    :integer
#  wallet_withdrawal_id :integer
#  wallet_load_id       :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  card_atm_withdrawal_id    :integer
#

class CompanyBalanceHistory < ActiveRecord::Base
  belongs_to :company

  belongs_to :neft_transfer, class_name: "Amount"
  belongs_to :company_balance, class_name: "Amount"
  belongs_to :company_withdrawal_to_card, class_name: "Amount"
  belongs_to :company_withdrawal_to_wallet, class_name: "Amount"
  belongs_to :company_load_from_card, class_name: "Amount"
  belongs_to :company_load_from_wallet, class_name: "Amount"
  belongs_to :card_withdrawal_to_virtual_account, class_name: "Amount"
  belongs_to :card_withdrawal_to_card, class_name: "Amount"
  belongs_to :card_withdrawal_to_wallet, class_name: "Amount"
  belongs_to :card_balance, class_name: "Amount"
  belongs_to :card_load_from_wallet, class_name: "Amount"
  belongs_to :card_load_from_virtual_account, class_name: "Amount"
  belongs_to :card_load_from_card, class_name: "Amount"
  belongs_to :card_expenses, class_name: "Amount"
  belongs_to :card_atm_withdrawal, class_name: "Amount"
  belongs_to :wallet_balance, class_name: "Amount"
  belongs_to :wallet_withdrawal_to_virtual_account, class_name: "Amount"
  belongs_to :wallet_withdrawal_to_wallet, class_name: "Amount"
  belongs_to :wallet_withdrawal_to_card, class_name: "Amount"
  belongs_to :wallet_load_from_virtual_account, class_name: "Amount"
  belongs_to :wallet_load_from_card, class_name: "Amount"
  belongs_to :wallet_load_from_wallet, class_name: "Amount"


  accepts_nested_attributes_for :neft_transfer, 
                                :company_balance, 
                                :company_withdrawal_to_card, :compay_withdrawal_to_wallet, 
                                :company_load_from_card, :company_load_from_wallet,
                                :card_load_from_virtual_account, :card_load_from_wallet, :card_load_from_card,
                                :card_withdrawal_to_card, :card_withdrawal_to_wallet, :card_withdrawal_to_virtual_account,
                                :card_balance, :card_expenses, :card_atm_withdrawal,
                                :wallet_load_from_wallet, :wallet_load_from_virtual_account, :wallet_load_from_card,
                                :wallet_balance,
                                :wallet_withdrawal_to_card, :wallet_withdrawal_to_wallet, :wallet_withdrawal_to_virtual_account


  delegate :company_balance_value, to: :company_balance
  delegate :company_load_from_card_value, to: :company_load_from_card
  delegate :company_load_from_wallet, to: :company_load_from_wallet
  delegate :company_withdrawal_to_card_value, to: :company_withdrawal_to_card
  delegate :company_withdrawal_to_wallet_value, to: :company_withdrawal_to_wallet
  delegate :card_balance_value, to: :card_balance
  delegate :card_withdrawal_to_card_value, to: :card_withdrawal_to_card
  delegate :card_withdrawal_to_wallet_value, to: :card_withdrawal_to_wallet
  delegate :card_withdrawal_to_virtual_account_value, to: :card_withdrawal_to_virtual_account
  delegate :card_load_from_card_value, to: :card_load_from_card
  delegate :card_load_from_wallet_value, to: :card_load_from_wallet
  delegate :card_load_from_virtual_account_value, to: :card_load_from_virtual_account
  delegate :card_expenses_value, to: :card_expenses
  delegate :card_atm_withdrawal_value, to: :card_atm_withdrawal
  delegate :wallet_load_from_card_value, to: :wallet_load_from_card
  delegate :wallet_load_from_wallet_value, to: :wallet_load_from_wallet
  delegate :wallet_load_from_virtual_account_value, to: :wallet_load_from_virtual_account
  delegate :wallet_withdrawal_to_card_value, to: :wallet_withdrawal_to_card
  delegate :wallet_withdrawal_to_wallet_value, to: :wallet_withdrawal_to_wallet
  delegate :wallet_withdrawal_to_virtual_account_value, to: :wallet_withdrawal_to_virtual_account
  delegate :wallet_balance_value, to: :wallet_balance

end
