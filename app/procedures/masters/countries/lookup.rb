class Masters::Countries::Lookup < Lookup::API

  resolver 'countries.default'
  search_key :name_cont

  attribute :id, visible: false
  attribute :name
end