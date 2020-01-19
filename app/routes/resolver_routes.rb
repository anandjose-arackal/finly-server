Resolver::Router.draw do
  # allow_multiple_associations!
  # scope "department" do
  #   route "submit", Masters::Departments::AutoComplete
  # end
  # with_options company_1: 1, env_1: :dev do
  #   route "departments", Masters::Departments::AutoComplete, :department_2, options: {company: 156, env: :dev}
  #   route "departments", :department
  # end
  scope :department do
    route "default", Masters::Departments::Resolver
  end
  scope :location do
    route "default", Masters::Locations::Resolver
  end
  scope :cost_center do
    route "default", Masters::CostCenters::Resolver
  end
end