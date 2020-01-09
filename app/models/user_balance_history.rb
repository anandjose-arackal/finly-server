# == Schema Information
#
# Table name: user_balance_histories
#
#  id                         :integer          not null, primary key
#  date                       :date
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

class UserBalanceHistory < ApplicationRecord
  belongs_to :user, optional: true

  belongs_to :card_balance, optional: true, class_name: "Amount"
  belongs_to :card_withdrawal, optional: true, class_name: "Amount"
  belongs_to :card_load, optional: true, class_name: "Amount"
  belongs_to :finly_money_balance, optional: true, class_name: "Amount"
  belongs_to :finly_money_withdrawal, optional: true, class_name: "Amount"
  belongs_to :finly_money_load, optional: true, class_name: "Amount"
  belongs_to :cash_on_hand_balance, optional: true, class_name: "Amount"
  belongs_to :cash_on_hand_withdrawal, optional: true, class_name: "Amount"
  belongs_to :cash_on_hand_load, optional: true, class_name: "Amount"
  belongs_to :card_expenses, optional: true, class_name: "Amount"
  belongs_to :card_atm_withdrawal, optional: true, class_name: "Amount"

  validates :date, presence: true
  validates :date, uniqueness: {scope: [:user_id]}
  validates :user, presence: true
  validates :card_balance, presence: true
  validates :card_withdrawal, presence: true
  validates :card_load, presence: true
  validates :finly_money_balance, presence: true
  validates :finly_money_load, presence: true
  validates :finly_money_withdrawal, presence: true
  validates :cash_on_hand_balance, presence: true
  validates :cash_on_hand_withdrawal, presence: true
  validates :cash_on_hand_load, presence: true
  validates :card_expenses, presence: true
  validates :card_atm_withdrawal, presence: true

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

  scope :with_date, ->(date) { where date: date }

end
