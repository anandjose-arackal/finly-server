# == Schema Information
#
# Table name: company_balance_histories
#
#  id                                      :integer          not null, primary key
#  company_id                              :integer
#  neft_transfer_id                        :integer
#  company_balance_id                      :integer
#  company_withdrawal_to_card_id           :integer
#  company_load_from_card_id               :integer
#  card_load_from_wallet_id                :integer
#  card_withdrawal_to_wallet_id            :integer
#  card_balance_id                         :integer
#  card_expenses_id                        :integer
#  wallet_load_from_wallet_id              :integer
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  card_atm_withdrawal_id                  :integer
#  company_withdrawal_to_wallet_id         :integer
#  company_load_from_wallet_id             :integer
#  card_withdrawal_to_card_id              :integer
#  card_withdrawal_to_virtual_account_id   :integer
#  card_load_from_card_id                  :integer
#  card_load_from_virtual_account_id       :integer
#  wallet_withdrawal_to_wallet_id          :integer
#  wallet_withdrawal_to_card_id            :integer
#  wallet_withdrawal_to_virtual_account_id :integer
#  wallet_load_from_card_id                :integer
#  wallet_load_from_virtual_account_id     :integer
#  date                                    :date
#  wallet_balance_id                       :integer
#  cash_on_hand_load_id                    :integer
#  cash_on_hand_withdrawal_id              :integer
#  cash_on_hand_balance_id                 :integer
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
  belongs_to :cash_on_hand_load, class_name: "Amount"
  belongs_to :cash_on_hand_balance, class_name: "Amount"
  belongs_to :cash_on_hand_withdrawal, class_name: "Amount"


  accepts_nested_attributes_for :neft_transfer
  accepts_nested_attributes_for :company_balance
  accepts_nested_attributes_for :company_withdrawal_to_card
  accepts_nested_attributes_for :company_withdrawal_to_wallet
  accepts_nested_attributes_for :company_load_from_card
  accepts_nested_attributes_for :company_load_from_wallet
  accepts_nested_attributes_for :card_load_from_virtual_account
  accepts_nested_attributes_for :card_load_from_wallet
  accepts_nested_attributes_for :card_load_from_card

  accepts_nested_attributes_for :card_withdrawal_to_card
  accepts_nested_attributes_for :card_withdrawal_to_wallet
  accepts_nested_attributes_for :card_withdrawal_to_virtual_account
  accepts_nested_attributes_for :card_balance
  accepts_nested_attributes_for :card_expenses
  accepts_nested_attributes_for :card_atm_withdrawal
  accepts_nested_attributes_for :wallet_load_from_wallet
  accepts_nested_attributes_for :wallet_load_from_virtual_account
  accepts_nested_attributes_for :wallet_load_from_card
  accepts_nested_attributes_for :wallet_balance
  accepts_nested_attributes_for :wallet_withdrawal_to_card
  accepts_nested_attributes_for :wallet_withdrawal_to_wallet
  accepts_nested_attributes_for :wallet_withdrawal_to_virtual_account
  accepts_nested_attributes_for :cash_on_hand_balance
  accepts_nested_attributes_for :cash_on_hand_withdrawal
  accepts_nested_attributes_for :cash_on_hand_load


  validates_presence_of :date, presence: true
  validates_presence_of :date, uniqueness: {scope: [:company_id]}
  validates_presence_of :company_balance
  validates_presence_of :company_load_from_card
  validates_presence_of :company_load_from_wallet
  validates_presence_of :company_withdrawal_to_card
  validates_presence_of :company_withdrawal_to_wallet
  validates_presence_of :card_balance
  validates_presence_of :card_load_from_wallet
  validates_presence_of :card_load_from_card
  validates_presence_of :card_load_from_virtual_account
  validates_presence_of :card_withdrawal_to_wallet
  validates_presence_of :card_withdrawal_to_card
  validates_presence_of :card_withdrawal_to_virtual_account
  validates_presence_of :wallet_balance
  validates_presence_of :wallet_withdrawal_to_wallet
  validates_presence_of :wallet_withdrawal_to_card
  validates_presence_of :wallet_withdrawal_to_virtual_account
  validates_presence_of :wallet_load_from_card
  validates_presence_of :wallet_load_from_virtual_account
  validates_presence_of :wallet_load_from_wallet
  validates_presence_of :cash_on_hand_balance
  validates_presence_of :cash_on_hand_withdrawal
  validates_presence_of :cash_on_hand_load



  delegate :company_balance_value, to: :company_balance
  delegate :company_load_from_card_value, to: :company_load_from_card
  delegate :company_load_from_wallet_value, to: :company_load_from_wallet
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
  delegate :cash_on_hand_balance_value, to: :cash_on_hand_balance
  delegate :cash_on_hand_load_value, to: :cash_on_hand_load
  delegate :cash_on_hand_withdrawal_value, to: :cash_on_hand_withdrawal

  scope :with_date, -> (date) {where date: date}

end
