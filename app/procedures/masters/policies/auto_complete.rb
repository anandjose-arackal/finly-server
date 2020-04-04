class Masters::Policies::AutoComplete < AutoComplete::API

  resolver 'policies.default'
  json :id, :name
  search_key :name_cont

end