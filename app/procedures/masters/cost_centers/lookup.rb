class Masters::CostCenters::Lookup < Lookup::API

  resolver 'cost_centers.default'
  search_key :name_or_cost_center_code_cont
  data_card_route 'masters.cost_centers'

  attribute :id, visible: false
  # attribute :cost_center_code
  attribute :name

end