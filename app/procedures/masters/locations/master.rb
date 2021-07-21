class Masters::Locations::Master < Masters::API

  model BranchLocation
  name "Branch Locations"

  schema has_nesting: true do
    sequence :location_code, prefix: 'LOC', min_length: 6, show_in_lookup: true
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :gl_code, show_in_lookup: true
    large_text :address_1
    large_text :address_2
    text :city
    lookup :state_id, choices_scope: Choices[:lookup].('states')
    text :country
    text :pin_code
    switch :billable_location
    switch :shippable_location
    text :pan
    text :tax_registration_number
    date :start_date
    date :end_date
  end


end