class Masters::Locations::AutoComplete < AutoComplete::API

  resolver Masters::Locations::Resolver
  json :id, :name
  search_key :name_or_location_code_cont

end