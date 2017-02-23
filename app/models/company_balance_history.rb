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
#  card_spend_id             :integer
#  finly_money_balance_id    :integer
#  finly_money_withdrawal_id :integer
#  finly_money_load_id       :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

class CompanyBalanceHistory < ActiveRecord::Base
  belongs_to :company

  belongs_to :neft_transfer, class_name: "Amount"
  belongs_to :company_balance, class_name: "Amount"
  belongs_to :company_withdrawal, class_name: "Amount"
  belongs_to :company_load, class_name: "Amount"
  belongs_to :card_withdrawal, class_name: "Amount"
  belongs_to :card_balance, class_name: "Amount"
  belongs_to :card_load, class_name: "Amount"
  belongs_to :card_spend, class_name: "Amount"
  belongs_to :finly_money_balance, class_name: "Amount"
  belongs_to :finly_money_withdrawal, class_name: "Amount"
  belongs_to :finly_money_load, class_name: "Amount"


  accepts_nested_attributes_for :neft_transfer, :company_balance, :company_withdrawal, :company_load,
                                :card_load, :card_withdrawal, :card_balance, :card_spend,
                                :finly_money_load, :finly_money_balance, :finly_money_withdrawal

  delegate :company_balance_value, to: :company_balance
  delegate :company_load_value, to: :company_load
  delegate :company_withdrawal_value, to: :company_withdrawal
  delegate :card_balance_value, to: :card_balance
  delegate :card_withdrawal_value, to: :card_withdrawal
  delegate :card_load_value, to: :card_load
  delegate :card_spend_value, to: :card_spend
  delegate :finly_money_load_value, to: :finly_money_load
  delegate :finly_money_withdrawal_value, to: :finly_money_withdrawal
  delegate :finly_money_balance_value, to: :finly_money_balance

end
