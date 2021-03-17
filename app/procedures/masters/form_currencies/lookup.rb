class Masters::FormCurrencies::Lookup < Lookup::API

  resolver 'form_currencies.default'
  search_key :currency_code_or_currency_or_symbol

  attribute :id, visible: false
  attribute :currency_code
  attribute :name, value: '{{record.currency}}'
  attribute :currency
  attribute :symbol
  attribute :currency_conversion_rate
end