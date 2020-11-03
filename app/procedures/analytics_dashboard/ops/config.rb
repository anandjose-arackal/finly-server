class AnalyticsDashboard::Ops::Config < Transactions::API

  CUBES = [
      {
          label: 'Invoice',
          cube: "Invoices",
          root: true,
          associations: %w(InvoicesLineItems BillingLocations ShippingLocations Vendors CostCenters Departments)
      },
      {
          label: 'Invoice Line Items',
          cube: "InvoicesLineItems",
          root: true,
          associations: %w(Invoices BillingLocations ShippingLocations Vendors CostCenters Departments)
      },
      {
          label: 'Vendor',
          cube: 'Vendors',
          root: true
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
    context[:token] = JWT.encode(
        {u:
             {id: current_user.id, company_id: current_user.company_id},
         exp: 3.hour.from_now.to_i},
        Rails.configuration.cube_js.api_key
    )
  end

  def build_config(context, current_user:, **)
    context[:base_url] = Rails.configuration.cube_js.base_url
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