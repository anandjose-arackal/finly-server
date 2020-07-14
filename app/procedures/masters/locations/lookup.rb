class Masters::Locations::Lookup < Lookup::API

  resolver 'location.default'
  search_key :name_or_location_code_cont

  attribute :id, visible: false
  attribute :location_code
  attribute :name

end