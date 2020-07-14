class Masters::CostCenters::Lookup < Lookup::API

  resolver 'cost_center.default'
  search_key :name_or_cost_center_code_cont

  attribute :id, visible: false
  # attribute :cost_center_code
  attribute :name

end