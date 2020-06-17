class Masters::Departments::Lookup < Lookup::API

  resolver 'department.default'
  search_key :name_or_code_cont

  attribute :id, visible: false
  attribute :department_code
  attribute :name

end