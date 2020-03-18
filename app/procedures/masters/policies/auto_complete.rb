class Masters::Policies::AutoComplete < AutoComplete::API

  resolver Masters::Policies::Resolver
  json :id, :name

end