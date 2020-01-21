AutoComplete::Router.draw do
  # allow_multiple_associations!
  # scope "department" do
  #   route "submit", Masters::Departments::AutoComplete
  # end
  # with_options company_1: 1, env_1: :dev do
  #   route "departments", Masters::Departments::AutoComplete, :department_2, options: {company: 156, env: :dev}
  #   route "departments", :department
  # end
  route "departments", Masters::Departments::AutoComplete
  route "locations", Masters::Locations::AutoComplete
  route "cost_centers", Masters::CostCenters::AutoComplete
  route "categories", Masters::Categories::AutoComplete
  route "policies", Masters::Policies::AutoComplete
end