class Masters::TaxRates::Lookup < Lookup::API

  resolver 'tax_rates.default'
  search_key :name_or_rate_or_internal_id_cont

  attribute :id, visible: false
  attribute :name
  attribute :rate

end