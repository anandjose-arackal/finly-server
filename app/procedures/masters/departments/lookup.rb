class Masters::Departments::Lookup < Lookup::API

  resolver 'departments.default'
  search_key :name_or_department_code_cont
  data_card_route 'masters.departments'

  attribute :id, visible: false
  attribute :department_code
  attribute :name

end