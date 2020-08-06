class Masters::Categories::Master < Masters::API

  model Category

  schema can_attributes_be_nested: true do
    text :parent_id
    text :name, required: true, show_in_lookup: true
    text :gl_code, show_in_lookup: true
  end

end