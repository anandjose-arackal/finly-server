class Masters::Categories::Master < Masters::API

  model Category

  schema can_attributes_be_nested: true do
    text :name, required: true
    text :gl_code
    switch :active
  end

end