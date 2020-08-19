class Masters::Locations::Master < Masters::API

  model BranchLocation

  schema can_attributes_be_nested: true do
    sequence :location_code, prefix: 'LOC/', min_length: 6, show_in_lookup: true
    text :parent_id
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :gl_code, show_in_lookup: true
    large_text :address_1
    large_text :address_2
    text :city
    text :state
    dropdown :country_id
    text :pin
    switch :billable_location
    switch :shippable_location
  end

end