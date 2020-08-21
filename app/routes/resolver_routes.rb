Resolver::Router.draw do
  # allow_multiple_associations!
  # scope "department" do
  #   route "submit", Masters::Departments::AutoComplete
  # end
  # with_options company_1: 1, env_1: :dev do
  #   route "departments", Masters::Departments::AutoComplete, :department_2, options: {company: 156, env: :dev}
  #   route "departments", :department
  # end

  # Admin
  scope :admin do
    scope :macros do
      route 'default', Admin::Masters::Macros::Resolver
    end

    scope :macro_jobs do
      route 'default', Admin::Masters::Macros::Jobs::Resolver
    end
  end

  # Masters
  scope :master_schemas do
    route 'default', Masters::Schema::Resolver
  end

  scope :department do
    route 'default', Masters::Departments::Resolver
  end

  scope :location do
    route 'default', Masters::Locations::Resolver
  end

  scope :cost_center do
    route 'default', Masters::CostCenters::Resolver
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
    scope :locations do
      route "default", Masters::Vendors::Locations::Resolver
    end
    scope :bank_accounts do
      route 'default', Masters::Vendors::BankAccounts::Resolver
    end
  end

  scope :vendor_types do
    route 'default', Masters::Vendors::Types::Resolver
  end

  scope :payment_terms do
    route 'default', Masters::PaymentTerms::Resolver
  end

  scope :items do
    route "default", Masters::Items::Resolver
  end

  scope :tax_rates do
    route 'default', Masters::TaxRates::Resolver
  end

  scope :tds_slabs do
    route 'default', Masters::TdsSlabs::Resolver
  end

  scope :users do
    route 'default', Masters::Users::Resolver
  end

  scope :rate_contracts do
    route 'default', Masters::RateContracts::Resolver
  end

  scope :utility_subscriptions do
    route 'default', Docs::UtilityBills::Subscriptions::Resolver
  end

  scope :bbps_billers do
    route 'default', Docs::UtilityBills::Billers::Resolver
  end

  scope :agreements do
    route 'default', Docs::P2P::Agreements::Resolver
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
    route 'advances', Docs::P2P::PurchaseOrders::Advances::Resolver
  end

  scope :inward_documents do
    route 'pending', Docs::P2P::Inwards::Pending::Resolver
    route 'received', Docs::P2P::Inwards::Received::Resolver
  end

  scope :credit_notes do
    route 'default', Docs::P2P::CreditNotes::Resolver
  end

  scope :utility_bills do
    route 'default', Docs::UtilityBills::Bills::Resolver
  end

  scope :payment_tickets do
    route 'default', Docs::PaymentTickets::Resolver
  end

  scope :payments do
    route 'default', Docs::PaymentTickets::Payments::Resolver
  end

  scope :upcoming_invoices do
    route 'default', Docs::P2P::Invoices::Agreement::UpcomingInvoices::Resolver
  end

  scope :reports do
    route 'default', Docs::ExpenseManagement::Reports::Resolver
  end

  scope :import_jobs do
    route 'default', ImportJobs::Resolver
  end
end