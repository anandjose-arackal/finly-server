class Masters::Categories::Master < Masters::API

  model Category

  schema can_attributes_be_nested: true do
    sequence :category_code, prefix: "CAT/", min_length: 6, show_in_lookup: true
    text :parent_id
    text :name, required: true, show_in_lookup: true
    text :gl_code, show_in_lookup: true
  end

end