Masters::Router.draw do
  route 'categories', Masters::Categories::Master
  route 'items', Masters::Items::Master
  route 'locations', Masters::Locations::Master
  route 'departments', Masters::Departments::Master
  route 'cost_centers', Masters::CostCenters::Master
end