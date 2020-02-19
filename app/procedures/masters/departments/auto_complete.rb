class Masters::Departments::AutoComplete < AutoComplete::API

  resolver Masters::Departments::Resolver
  json :id, :name

end