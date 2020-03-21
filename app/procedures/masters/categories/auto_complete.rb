class Masters::Categories::AutoComplete < AutoComplete::API

  resolver Masters::Categories::Resolver
  json :id, :name
  search_key :name_or_category_code_cont

end