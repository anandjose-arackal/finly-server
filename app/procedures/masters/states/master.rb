class Masters::Locations::State < Masters::API

  model State
  name "States"

  schema has_nesting: false do
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :code
    text :state_code
  end


end