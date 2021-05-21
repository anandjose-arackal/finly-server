class Masters::Currencies::Lookup < Lookup::API

  resolver 'currencies.default'
  search_key :country_code_or_country_start
  # _or_symbol

  attribute :id, visible: false
  attribute :country_code
  attribute :currency_code, value: '{{record.country_code}}'
  
  attribute :name, value: '{{record.country_code}}'
  attribute :country 
  attribute :currency, value: '{{record.country}}' 

  attribute :symbol
  attribute :currency_conversion_rate
end