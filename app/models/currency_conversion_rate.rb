# == Schema Information
#
# Table name: currency_conversion_rates
#
#  id         :integer          not null, primary key
#  date       :date             not null
#  INR        :decimal(10, 5)
#  USD        :decimal(10, 5)
#  GBP        :decimal(10, 5)
#  EUR        :decimal(10, 5)
#  CAD        :decimal(10, 5)
#  HRK        :decimal(10, 5)
#  RUB        :decimal(10, 5)
#  BGN        :decimal(10, 5)
#  BRL        :decimal(10, 5)
#  CHF        :decimal(10, 5)
#  CNY        :decimal(10, 5)
#  CZK        :decimal(10, 5)
#  DKK        :decimal(10, 5)
#  HKD        :decimal(10, 5)
#  HUF        :decimal(10, 5)
#  IDR        :decimal(10, 5)
#  ILS        :decimal(10, 5)
#  JPY        :decimal(10, 5)
#  KRW        :decimal(10, 5)
#  MXN        :decimal(10, 5)
#  MYR        :decimal(10, 5)
#  NOK        :decimal(10, 5)
#  NZD        :decimal(10, 5)
#  PHP        :decimal(10, 5)
#  PLN        :decimal(10, 5)
#  RON        :decimal(10, 5)
#  SEK        :decimal(10, 5)
#  SGD        :decimal(10, 5)
#  THB        :decimal(10, 5)
#  TRY        :decimal(10, 5)
#  ZAR        :decimal(10, 5)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CurrencyConversionRate < ActiveRecord::Base

  validates :date, presence: true, uniqueness: true

end
