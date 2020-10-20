class Masters::Locations::AutoComplete < AutoComplete::API

  resolver 'locations.default'
  json :id, :name
  search_key :name_or_location_code_cont

end