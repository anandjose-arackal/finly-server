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


require 'test_helper'

class AmountTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
