class Masters::Vendors::AutoComplete < AutoComplete::API

  resolver Masters::Vendors::Resolver
  json :id, :name

end