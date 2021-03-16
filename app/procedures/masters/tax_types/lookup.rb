class Masters::TaxTypes::Lookup < Lookup::API

  resolver 'tax_types.default'
  search_key :name

  attribute :id, visible: false
  attribute :name
end