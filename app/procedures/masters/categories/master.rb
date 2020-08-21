class Masters::Categories::Master < Masters::API

  model Category

  schema do
    sequence :category_code, prefix: "CAT/", min_length: 6, show_in_lookup: true
    parent_lookup
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :gl_code, show_in_lookup: true
    date :start_date
    date :end_date
  end

end