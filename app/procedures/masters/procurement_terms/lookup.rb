class Masters::ProcurementTerms::Lookup < Lookup::API

  resolver 'procurement_terms.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
  attribute :text
end