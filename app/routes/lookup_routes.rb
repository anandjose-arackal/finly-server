Lookup::Router.draw do

  # Masters
  route 'policies', Masters::Policies::Lookup
  route "departments", Masters::Departments::Lookup
  route "locations", Masters::Locations::Lookup
  route "cost_centers", Masters::CostCenters::Lookup
  route "categories", Masters::Categories::Lookup
  route "vendors", Masters::Vendors::Lookup # Went with singular because plural was already being used by other areas of the app
  route "items", Masters::Items::Lookup
  route 'bbps_billers', Docs::UtilityBills::Billers::Lookup

  # Docs
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Lookup

end