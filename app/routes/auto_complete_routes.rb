AutoComplete::Router.draw do
  # allow_multiple_associations!
  # scope "department" do
  #   route "submit", Masters::Departments::AutoComplete
  # end
  # with_options company_1: 1, env_1: :dev do
  #   route "departments", Masters::Departments::AutoComplete, :department_2, company: 156, env: :dev
  #   route "departments", :department
  # end

  # Masters
  route "departments", Masters::Departments::AutoComplete
  route "locations", Masters::Locations::AutoComplete
  route "cost_centers", Masters::CostCenters::AutoComplete
  route "categories", Masters::Categories::AutoComplete
  route "policies", Masters::Policies::AutoComplete
  route "vendor", Masters::Vendors::AutoComplete # Went with singular because plural was already being used by other areas of the app
  route "items", Masters::Items::AutoComplete
  route 'bbps_billers', Docs::UtilityBills::Billers::AutoComplete
  route 'users', Masters::Users::AutoComplete

  # Docs
  route 'purchase_requests', Docs::P2P::PurchaseRequests::AutoComplete
end