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

  scope :insight_dashboard do
    route 'default', Insights::Resolver
  end

  scope :category do
    route 'default', Masters::Categories::Resolver
  end

  scope :trips do
    route 'default', Docs::Trips::Resolver
  end

  scope :invoices do
    route "default", Docs::P2P::Invoices::Resolver
    route "po", Docs::P2P::Invoices::Resolver
    route "non_po", Docs::P2P::Invoices::Resolver
    route "agreement", Docs::P2P::Invoices::Resolver
  end

  scope :index_view_segments do
    route "default", IndexSegment::Resolver
  end

  scope :policies do
    route "default", Masters::Policies::Resolver
  end

  scope :vendors do
    route "default", Masters::Vendors::Resolver
  end

end