class Masters::CostCenters::AutoComplete < AutoComplete::API

  resolver 'cost_centers.default'
  json :id, :name
  search_key :name_or_cost_center_code_cont

end