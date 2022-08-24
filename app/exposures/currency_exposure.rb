class CurrencyExposure < Exposures::API

  attribute :id, record_attribute: true
  attribute :symbol, record_attribute: true
  attribute :country, record_attribute: true
  attribute :currency do 
    record.country
  end

  attribute :country_code, record_attribute: true
  attribute :currency_code do 
    record.country_code
  end
  
  attribute :currency_conversion_rate do
    record.currency_conversion_rate(Date.parse(registers["conversion_date"]), Currency.find_by(id: registers["to_currency"]).country_code).round(5) rescue 1
  end
end