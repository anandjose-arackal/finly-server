class AnalyticsDashboard::Ops::Config < Transactions::API

  CUBES = [
      {
          label: 'Purchase Requests',
          cube: "PurchaseRequests",
          root: true,
          associations: %w(PurchaseRequestLineItems CostCenters Departments ShippingLocations Initiator)
      },
      {
          label: 'Purchase Orders',
          cube: "PurchaseOrders",
          root: true,
          associations: %w(PurchaseOrderLineItems CostCenters Departments BillingLocations ShippingLocations PaymentTerms Vendors Initiator)
      },
      {
          label: 'Invoices',
          cube: "Invoices",
          root: true,
          associations: %w(InvoiceLineItems CostCenters Departments BillingLocations ShippingLocations PaymentTerms Vendors Initiator)
      },
      {
          label: 'Payments',
          cube: "VendorPayments",
          root: true,
          associations: %w(PaymentTickets)
      },
      {
          label: 'Payment Tickets',
          cube: "PaymentTickets",
          root: false
      },
      {
          label: 'Vendors',
          cube: 'Vendors',
          root: true
      },
      {
          label: 'Users',
          cube: "VpUsers",
          root: true
      },
      {
          label: 'Purchase Request Line Items',
          cube: 'PurchaseRequestLineItems',
          root: false
      },
      {
          label: 'Purchase Order Line Items',
          cube: 'PurchaseOrderLineItems',
          root: false
      },
      {
          label: 'Invoice Line Items',
          cube: "InvoiceLineItems",
          root: false
      },
      {
          label: 'Billing Location',
          cube: "BillingLocations",
          root: false
      },
      {
          label: 'Shipping Location',
          cube: "ShippingLocations",
          root: false
      },
      {
          label: 'Initiator',
          cube: "Initiator",
          root: false
      },
      {
          label: 'Payment Terms',
          cube: "PaymentTerms",
          root: false
      }
  ].freeze

  pass :generate_token
  pass :build_config

  def generate_token(context, current_user:, **)
    context[:token] = CubeJs.generate_token(current_user)
    context[:expires_in] = CubeJs::DEFAULT_EXPIRES_IN.to_i
  end

  def build_config(context, current_user:, **)
    context[:base_url] = CubeJs.base_url
    context[:config] = []
    CUBES.each do |cube|
      next unless authorized?(current_user, cube)

      context[:config] << cube
    end
    toggle = AnalyticsToggle.new(current_user)
    context[:toggles] = {
        maximum_reports: toggle.maximum_reports,
        custom_reports_enabled: toggle.custom_reports_enabled?,
        maximum_dashboards: toggle.maximum_dashboards,
        drilldowns_enabled: toggle.drilldowns_enabled?,
        custom_dashboards_enabled: toggle.custom_dashboards_enabled?,
    }
  end

  private

  def authorized?(current_user, config)
    return false unless current_user.present?
    return false unless config[:permissions].blank? or current_user.has_permission?(config[:permissions])
    return false unless company_subscribed?(current_user, config)

    true
  end

  def company_subscribed?(current_user, config)
    return true if config[:features].blank?

    features = config[:features]
    features = [config[:features]] unless features.respond_to?(:each)

    features.each do |feature|
      return false unless !!current_user.company.feature_subscription.send(feature)
    end

    true
  end

end