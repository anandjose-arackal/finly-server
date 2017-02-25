# == Schema Information
#
# Table name: user_balance_histories
#
#  id                         :integer          not null, primary key
#  date                       :datetime
#  user_id                    :integer
#  company_id                 :integer
#  card_balance_id            :integer
#  card_withdrawal_id         :integer
#  card_load_id               :integer
#  card_expenses_id           :integer
#  finly_money_balance_id     :integer
#  finly_money_withdrawal_id  :integer
#  finly_money_load_id        :integer
#  cash_on_hand_balance_id    :integer
#  cash_on_hand_withdrawal_id :integer
#  cash_on_hand_load_id       :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  card_atm_withdrawal_id     :integer
#

class UserBalanceHistory < ActiveRecord::Base
  belongs_to :user

  belongs_to :card_balance, class_name: "Amount"
  belongs_to :card_withdrawal, class_name: "Amount"
  belongs_to :card_load, class_name: "Amount"
  belongs_to :finly_money_balance, class_name: "Amount"
  belongs_to :finly_money_withdrawal, class_name: "Amount"
  belongs_to :finly_money_load, class_name: "Amount"
  belongs_to :cash_on_hand_balance, class_name: "Amount"
  belongs_to :cash_on_hand_withdrawal, class_name: "Amount"
  belongs_to :cash_on_hand_load, class_name: "Amount"
  belongs_to :card_expenses, class_name: "Amount"
  belongs_to :card_atm_withdrawal, class_name: "Amount"

  accepts_nested_attributes_for :card_balance, :card_withdrawal, :card_load, :card_atm_withdrawal, :card_expenses, :finly_money_load, :finly_money_balance, :finly_money_withdrawal,
                                :cash_on_hand_load, :cash_on_hand_withdrawal, :cash_on_hand_balance

  delegate :card_balance_value, to: :card_balance
  delegate :card_withdrawal_value, to: :card_withdrawal
  delegate :card_load_value, to: :card_load
  delegate :card_atm_withdrawal_value, to: :card_atm_withdrawal
  delegate :card_expenses_value, to: :card_expenses
  delegate :finly_money_load_value, to: :finly_money_load
  delegate :finly_money_withdrawal_value, to: :finly_money_withdrawal
  delegate :finly_money_balance_value, to: :finly_money_balance
  delegate :cash_on_hand_load_value, to: :cash_on_hand_load
  delegate :cash_on_hand_withdrawal_value, to: :cash_on_hand_withdrawal
  delegate :cash_on_hand_balance_value, to: :cash_on_hand_balance
  
end
