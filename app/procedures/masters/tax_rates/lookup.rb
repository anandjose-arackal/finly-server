class Masters::TaxRates::Lookup < Lookup::API

  resolver 'tax_rates.default'
  search_key :name_or_rate_or_internal_id_cont_or_tax_type_name

  attribute :id, visible: false
  attribute :name
  # attribute :name, value: "{{ record.name }}-{{ record.rate }}"
  attribute :rate


end