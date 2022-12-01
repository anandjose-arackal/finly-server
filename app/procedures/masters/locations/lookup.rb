class Masters::Locations::Lookup < Lookup::API

  resolver 'locations.default'
  search_key :name_or_location_code_cont
  data_card_route 'masters.locations'

  attribute :id, visible: false
  attribute :location_code
  attribute :name

end