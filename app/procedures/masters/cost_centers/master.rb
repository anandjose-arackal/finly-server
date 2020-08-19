class Masters::CostCenters::Master < Masters::API

  model CostCenter

  schema can_attributes_be_nested: true do
    sequence :cost_center_code, prefix: "CC/", min_length: 6, show_in_lookup: true
    text :parent_id
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :gl_code, show_in_lookup: true
  end

end