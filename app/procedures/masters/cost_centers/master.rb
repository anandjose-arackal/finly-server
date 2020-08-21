class Masters::CostCenters::Master < Masters::API

  model CostCenter

  schema do
    sequence :cost_center_code, prefix: "CC/", min_length: 6, show_in_lookup: true
    text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
    text :gl_code, show_in_lookup: true
    date :start_date
    date :end_date
  end

end