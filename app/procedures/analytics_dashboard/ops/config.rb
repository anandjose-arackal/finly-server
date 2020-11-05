class AnalyticsDashboard::Ops::Config < Transactions::API

  CUBES = [
      {
          label: 'Invoice',
          cube: "Invoices",
          root: true,
          associations: %w(InvoiceLineItems BillingLocations ShippingLocations Vendors CostCenters Departments)
      },
      {
          label: 'Vendor',
          cube: 'Vendors',
          root: true
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
      }
  ].freeze

  pass :generate_token
  pass :build_config

  def generate_token(context, current_user:, **)
    context[:token] = CubeJs.generate_token(current_user)
  end

  def build_config(context, current_user:, **)
    context[:base_url] = CubeJs.base_url
    context[:config] = []
    CUBES.each do |cube|
      next unless authorized?(current_user, cube)

      context[:config] << cube
    end
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