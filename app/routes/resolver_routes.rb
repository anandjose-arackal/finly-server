Resolver::Router.draw do
  # allow_multiple_associations!
  # scope "department" do
  #   route "submit", Masters::Departments::AutoComplete
  # end
  # with_options company_1: 1, env_1: :dev do
  #   route "departments", Masters::Departments::AutoComplete, :department_2, options: {company: 156, env: :dev}
  #   route "departments", :department
  # end

  # Masters
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

  scope :index_view_segments do
    route "default", IndexSegment::Resolver
  end

  scope :policies do
    route "default", Masters::Policies::Resolver
  end

  scope :vendors do
    route "default", Masters::Vendors::Resolver
  end

  scope :vendor_types do
    route 'default', Masters::Vendors::Types::Resolver
  end

  scope :payment_terms do
    route 'default', Masters::PaymentTerms::Resolver
  end

  # Docs
  scope :trips do
    route 'default', Docs::Trips::Resolver
  end

  scope :invoices do
    route "default", Docs::P2P::Invoices::Resolver
    route "po", Docs::P2P::Invoices::Po::Resolver
    route "non_po", Docs::P2P::Invoices::NonPo::Resolver
    route "agreement", Docs::P2P::Invoices::Agreement::Resolver
  end

  scope :purchase_requests do
    route 'default', Docs::P2P::PurchaseRequests::Resolver
  end

  scope :purchase_orders do
    route 'default', Docs::P2P::PurchaseOrders::Resolver
  end

  scope :bbps_bills do
    route 'default', Docs::UtilityBills::Bills::Resolver
  end

end