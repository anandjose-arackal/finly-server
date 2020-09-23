class Masters::PaymentTerms::Lookup < Lookup::API

  resolver 'payment_terms.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
  attribute :description
  attribute :default

end