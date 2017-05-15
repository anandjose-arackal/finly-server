# == Schema Information
#
# Table name: currencies
#
#  id           :integer          not null, primary key
#  country      :string(255)
#  country_code :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  symbol       :string(255)
#


class Currency < ActiveRecord::Base
  has_many :amounts

  # since default currency is INR
  def self.default_currency_id
    1
  end

  CURRENCIES = [
      {
          country: "India",
          country_code: "INR",
          symbol: "₹"
      },
      {
          country: "United States of America",
          country_code: "USD",
          symbol: "$"
      },
      {
          country: "United Kingdom",
          country_code: "GBP",
          symbol: "£"
      },
      {
          country: "Australia",
          country_code: "AUD",
          symbol: "$"
      },
      {
          country: "Europe",
          country_code: "EUR",
          symbol: "€"
      },
      {
          country: "China",
          country_code: "CNY",
          symbol: "¥"
      },
      {
          country: "Japan",
          country_code: "JPY",
          symbol: "¥"
      },
      {
          country: "New Zealand",
          country_code: "NZD",
          symbol: "$"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },
      {
          country: "Russia",
          country_code: "RUB",
          symbol: "₽"
      },

  ]

  def self.seed_data
    CURRENCIES.each do |currency, index|
      if Currency.find_by(country_code: currency[:country_code]).present?
        next
      else
        Currency.create(country: currency[:country], country_code: currency[:country_code], symbol: currency[:symbol])
      end
    end
  end
end
