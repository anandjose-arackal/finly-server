class Masters::Departments::AutoComplete < AutoComplete::API

  resolver 'departments.default'
  json :id, :name
  search_key :name_or_code_cont

end