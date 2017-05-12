# == Schema Information
#
# Table name: amounts
#
#  id          :integer          not null, primary key
#  value       :decimal(64, 12)
#  currency_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  INR         :decimal(20, 5)
#  USD         :decimal(20, 5)
#  GBP         :decimal(20, 5)
#  CAD         :decimal(20, 5)
#  EUR         :decimal(20, 5)
#  HRK         :decimal(20, 5)
#  RUB         :decimal(20, 5)
#  BGN         :decimal(20, 5)
#  BRL         :decimal(20, 5)
#  CHF         :decimal(20, 5)
#  CNY         :decimal(20, 5)
#  CZK         :decimal(20, 5)
#  DKK         :decimal(20, 5)
#  HKD         :decimal(20, 5)
#  HUF         :decimal(20, 5)
#  IDR         :decimal(20, 5)
#  ILS         :decimal(20, 5)
#  JPY         :decimal(20, 5)
#  KRW         :decimal(20, 5)
#  MXN         :decimal(20, 5)
#  NOK         :decimal(20, 5)
#  NZD         :decimal(20, 5)
#  PHP         :decimal(20, 5)
#  PLN         :decimal(20, 5)
#  RON         :decimal(20, 5)
#  SEK         :decimal(20, 5)
#  SGD         :decimal(20, 5)
#  THB         :decimal(20, 5)
#  TRY         :decimal(20, 5)
#  ZAR         :decimal(20, 5)
#  AUD         :decimal(20, 5)
#

class Amount < ActiveRecord::Base
  include MathUtil
  belongs_to :currency

  validate :no_negative_amount

  validates :currency_id, presence: true
  validates :value, presence: true

  before_create do
    if self.value.nil?
      self.value = 0
    end
  end

  # method that returns the amount value
  def amount_value
    self.precision_value
  end

  # method that returns the value of the amount
  def budget_value
    self.precision_value
  end

  alias_method :transaction_amount_value, :amount_value
  alias_method :pending_reimbursement_value, :amount_value
  alias_method :billing_amount_value, :amount_value
  alias_method :card_balance_value, :amount_value
  alias_method :submitted_amount_value, :amount_value
  alias_method :card_amount_value, :amount_value
  alias_method :cash_on_hand_load_value, :amount_value
  alias_method :cash_on_hand_withdrawal_value, :amount_value
  alias_method :cash_on_hand_balance_value, :amount_value
  alias_method :card_load_value, :amount_value
  alias_method :card_withdrawal_value, :amount_value
  alias_method :card_expenses_value, :amount_value
  alias_method :finly_money_load_value, :amount_value
  alias_method :finly_money_balance_value, :amount_value
  alias_method :finly_money_withdrawal_value, :amount_value

  alias_method :company_balance_value, :amount_value
  alias_method :company_load_from_card_value, :amount_value
  alias_method :company_load_from_wallet, :amount_value
  alias_method :company_withdrawal_to_card_value, :amount_value
  alias_method :company_withdrawal_to_wallet_value, :amount_value
  alias_method :card_withdrawal_to_card_value, :amount_value
  alias_method :card_withdrawal_to_wallet_value, :amount_value
  alias_method :card_withdrawal_to_virtual_account_value, :amount_value
  alias_method :card_load_from_card_value, :amount_value
  alias_method :card_load_from_wallet_value, :amount_value
  alias_method :card_load_from_virtual_account_value, :amount_value
  alias_method :wallet_load_from_card_value, :amount_value
  alias_method :wallet_load_from_wallet_value, :amount_value
  alias_method :wallet_load_from_virtual_account_value, :amount_value
  alias_method :wallet_withdrawal_to_card_value, :amount_value
  alias_method :wallet_withdrawal_to_wallet_value, :amount_value
  alias_method :wallet_withdrawal_to_virtual_account_value, :amount_value
  alias_method :wallet_balance_value, :amount_value

  alias_method :rate_value, :amount_value

  scope :with_id, -> (id) { where id: id }

  def greater_than_amount_value
    self.value
  end

  def greater_than_amount_currency_id
    self.currency_id
  end

  # method that returns the currency code
  def currency_country_code
    self.currency.country_code
  end

  def precision_value
    super(self.value)
  end

  def as_json(options={})
    {value: self.value,
     currency: {
         id: self.currency.id,
         country: self.currency.country,
         country_code: self.currency.country_code,
         symbol: self.currency.symbol}}
  end

  private

  def no_negative_amount
    if self.value and self.value < 0
      errors.add(:amount, 'cannot be negative')
    end
  end

end
