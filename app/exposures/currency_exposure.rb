class CurrencyExposure < Exposures::API

  attribute :symbol, record_attribute: true
  attribute :country, record_attribute: true
  attribute :country_code, record_attribute: true

end