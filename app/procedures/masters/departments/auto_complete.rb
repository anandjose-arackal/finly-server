class Masters::Departments::AutoComplete < AutoComplete::API

  resolver Masters::Departments::Resolver
  json :id, :name
  search_key :name_or_code_cont

end