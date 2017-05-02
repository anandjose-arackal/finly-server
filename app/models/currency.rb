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
          country_code: "INR"
      },
      {
          country: "United States of America",
          country_code: "USD"
      },
      {
          country: "United Kingdom",
          country_code: "GBP"
      },
      {
          country: "Australia",
          country_code: "AUD"
      },
      {
          country: "Europe",
          country_code: "EUR"
      },
      {
          country: "China",
          country_code: "CNY"
      },
      {
          country: "Japan",
          country_code: "JPY"
      },
      {
          country: "New Zealand",
          country_code: "NZD"
      },
      {
          country: "Russia",
          country_code: "RUB"
      }
  ]

  def self.seed_data
    CURRENCIES.each do |currency|
      if Currency.find_by(country_code: currency[:country_code]).present?
        next
      else
        Currency.create(country: currency[:country], country_code: currency[:country_code])
      end
    end
  end
end
