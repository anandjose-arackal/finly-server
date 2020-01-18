class Masters::Departments::AutoComplete < AutoComplete::API

  handle :departments
  resolver Masters::Departments::Resolver
  json :id, :name

end