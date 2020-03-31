class Masters::CostCenters::AutoComplete < AutoComplete::API

  resolver Masters::CostCenters::Resolver
  json :id, :name

end