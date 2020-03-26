class Masters::Categories::AutoComplete < AutoComplete::API

  resolver Masters::Categories::Resolver
  json :id, :name

end