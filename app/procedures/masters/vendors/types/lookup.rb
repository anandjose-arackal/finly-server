class Masters::Vendors::Types::Lookup < Lookup::API

  resolver 'vendors.types.default'
  search_key :name_or_description_cont

  attribute :id, visible: false
  attribute :name
  attribute :description

end