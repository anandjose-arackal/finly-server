class Masters::Locations::AutoComplete < AutoComplete::API

  resolver Masters::Locations::Resolver
  json :id, :name

end