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
#  AED         :decimal(20, 5)
#  AFN         :decimal(20, 5)
#  ALL         :decimal(20, 5)
#  AMD         :decimal(20, 5)
#  ANG         :decimal(20, 5)
#  AOA         :decimal(20, 5)
#  ARS         :decimal(20, 5)
#  AWG         :decimal(20, 5)
#  AZN         :decimal(20, 5)
#  BAM         :decimal(20, 5)
#  BBD         :decimal(20, 5)
#  BDT         :decimal(20, 5)
#  BHD         :decimal(20, 5)
#  BIF         :decimal(20, 5)
#  BMD         :decimal(20, 5)
#  BND         :decimal(20, 5)
#  BOB         :decimal(20, 5)
#  BSD         :decimal(20, 5)
#  BTC         :decimal(20, 5)
#  BTN         :decimal(20, 5)
#  BWP         :decimal(20, 5)
#  BYN         :decimal(20, 5)
#  BYR         :decimal(20, 5)
#  BZD         :decimal(20, 5)
#  CDF         :decimal(20, 5)
#  CLF         :decimal(20, 5)
#  CLP         :decimal(20, 5)
#  COP         :decimal(20, 5)
#  CRC         :decimal(20, 5)
#  CUC         :decimal(20, 5)
#  CUP         :decimal(20, 5)
#  CVE         :decimal(20, 5)
#  DJF         :decimal(20, 5)
#  DOP         :decimal(20, 5)
#  DZD         :decimal(20, 5)
#  EEK         :decimal(20, 5)
#  EGP         :decimal(20, 5)
#  ERN         :decimal(20, 5)
#  ETB         :decimal(20, 5)
#  FJD         :decimal(20, 5)
#  FKP         :decimal(20, 5)
#  GEL         :decimal(20, 5)
#  GGP         :decimal(20, 5)
#  GHS         :decimal(20, 5)
#  GIP         :decimal(20, 5)
#  GMD         :decimal(20, 5)
#  GNF         :decimal(20, 5)
#  GTQ         :decimal(20, 5)
#  GYD         :decimal(20, 5)
#  HNL         :decimal(20, 5)
#  HTG         :decimal(20, 5)
#  IMP         :decimal(20, 5)
#  IQD         :decimal(20, 5)
#  IRR         :decimal(20, 5)
#  ISK         :decimal(20, 5)
#  JEP         :decimal(20, 5)
#  JMD         :decimal(20, 5)
#  JOD         :decimal(20, 5)
#  KES         :decimal(20, 5)
#  KGS         :decimal(20, 5)
#  KHR         :decimal(20, 5)
#  KMF         :decimal(20, 5)
#  KPW         :decimal(20, 5)
#  KWD         :decimal(20, 5)
#  KYD         :decimal(20, 5)
#  KZT         :decimal(20, 5)
#  LAK         :decimal(20, 5)
#  LBP         :decimal(20, 5)
#  LKR         :decimal(20, 5)
#  LRD         :decimal(20, 5)
#  LSL         :decimal(20, 5)
#  LTL         :decimal(20, 5)
#  LVL         :decimal(20, 5)
#  LYD         :decimal(20, 5)
#  MAD         :decimal(20, 5)
#  MDL         :decimal(20, 5)
#  MGA         :decimal(20, 5)
#  MKD         :decimal(20, 5)
#  MMK         :decimal(20, 5)
#  MNT         :decimal(20, 5)
#  MOP         :decimal(20, 5)
#  MRO         :decimal(20, 5)
#  MUR         :decimal(20, 5)
#  MVR         :decimal(20, 5)
#  MWK         :decimal(20, 5)
#  MZN         :decimal(20, 5)
#  NAD         :decimal(20, 5)
#  NGN         :decimal(20, 5)
#  NIO         :decimal(20, 5)
#  NPR         :decimal(20, 5)
#  OMR         :decimal(20, 5)
#  PAB         :decimal(20, 5)
#  PEN         :decimal(20, 5)
#  PGK         :decimal(20, 5)
#  PKR         :decimal(20, 5)
#  PYG         :decimal(20, 5)
#  QAR         :decimal(20, 5)
#  RSD         :decimal(20, 5)
#  RWF         :decimal(20, 5)
#  SAR         :decimal(20, 5)
#  SBD         :decimal(20, 5)
#  SCR         :decimal(20, 5)
#  SDG         :decimal(20, 5)
#  SHP         :decimal(20, 5)
#  SLL         :decimal(20, 5)
#  SOS         :decimal(20, 5)
#  SRD         :decimal(20, 5)
#  STD         :decimal(20, 5)
#  SVC         :decimal(20, 5)
#  SYP         :decimal(20, 5)
#  SZL         :decimal(20, 5)
#  TJS         :decimal(20, 5)
#  TMT         :decimal(20, 5)
#  TND         :decimal(20, 5)
#  TOP         :decimal(20, 5)
#  TTD         :decimal(20, 5)
#  TWD         :decimal(20, 5)
#  TZS         :decimal(20, 5)
#  UAH         :decimal(20, 5)
#  UGX         :decimal(20, 5)
#  UYU         :decimal(20, 5)
#  UZS         :decimal(20, 5)
#  VEF         :decimal(20, 5)
#  VND         :decimal(20, 5)
#  VUV         :decimal(20, 5)
#  WST         :decimal(20, 5)
#  XAF         :decimal(20, 5)
#  XAG         :decimal(20, 5)
#  XAU         :decimal(20, 5)
#  XCD         :decimal(20, 5)
#  XDR         :decimal(20, 5)
#  XOF         :decimal(20, 5)
#  XPF         :decimal(20, 5)
#  YER         :decimal(20, 5)
#  ZMK         :decimal(20, 5)
#  ZMW         :decimal(20, 5)
#  ZWL         :decimal(20, 5)
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
  alias_method :minimum_balance_value, :amount_value

  alias_method :rate_value, :amount_value

  scope :with_id, -> (id) { where id: id }

  after_create {
    # i.e. updating the respective currency' column with value
    if Amount.column_names.include?(self.currency.country_code)
      self.update((self.currency.country_code) => self.value)
    end
  }

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

  def amount_with_currency(currency_code)
    currency_code = currency_code.to_sym unless currency_code.is_a?(Symbol)
    unless Amount.column_names.include?(currency_code)
      return
    end
    self.send(currency_code)
  end

  def as_json(options={})
    {value: self.value,
     currency: {
         id: self.currency.id,
         country: self.currency.country,
         country_code: self.currency.country_code,
         symbol: self.currency.symbol}}
  end

  def update_currencies(date)
    # i.e. if the expense is today's and the currency conversion data is not present
    if date == DateUtils.local_date
      return
    end
    date = date.strftime("%Y-%m-%d")
    update_hash = {}
    rate = CurrencyConversionRate.find_by(date: date)
    if rate.nil?
      return
    end
    currencies = CurrencyConversionRate.column_names.reject { |el| ['created_at', 'updated_at', 'date', 'id'].include?(el)}
    orig_curr = self.currency.country_code
    currencies.each do |curr|
      if Amount.column_names.include?(curr)
        currency_rate = rate.send(curr.to_sym).to_f
        normalized_amt = self.amount_value * currency_rate
        update_hash[curr.to_sym] = (normalized_amt/rate.send(orig_curr.to_sym))
      end
    end
    self.update(update_hash)
  end

  def destroy_currencies
    update_hash = {}
    currencies = Amount.column_names.reject { |el| ['created_at', 'updated_at', 'date', 'id', "#{self.currency.country_code}", 'value', 'currency_id'].include?(el)}
    currencies.each do |curr|
      update_hash[curr.to_sym] = nil
    end
    self.update(update_hash)
  end

  private

  def no_negative_amount
    if self.value and self.value < 0
      errors.add(:amount, 'cannot be negative')
    end
  end

end
