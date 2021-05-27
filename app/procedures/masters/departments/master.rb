class Masters::Departments::Master < Masters::API

  model Department
  name "Departments"

  schema has_nesting: true do
    sequence :department_code, prefix: 'DEPT/', min_length: 6, show_in_lookup: true
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :gl_code, show_in_lookup: true
    date :start_date
    date :end_date
  end

end