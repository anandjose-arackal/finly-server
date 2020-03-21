class Masters::Policies::AutoComplete < AutoComplete::API

  resolver Masters::Policies::Resolver
  json :id, :name
  search_key :name_cont

end