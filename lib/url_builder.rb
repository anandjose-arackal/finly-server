class UrlBuilder

  ROUTES = {
      purchase_requests: {
          show: 'purchase_request/{{record_id}}/params={}'
      },
      purchase_orders: {
          show: 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{procurement_id}}","procurement_type":"{{procurement_type}}"}'
      },
      invoices: {
          show: 'procure_invoice/{{record_id}}/params={"procurement_id":"{{procurement_id}}","procurement_type":"{{procurement_type}}"}'
      },
      payment_tickets: {
          show: 'orders/{{record_id}}/params={}'
      },
      payments: {
          show: 'orders/{{payment_ticket_id}}/params={}'
      },
      utility_bills: {
          show: 'utility_bill/{{record_id}}/params={}'
      },
      vendors: {
          show: 'vendor/{{record_id}}/params={}'
      },
      items: {
          show: 'inventory/{{record_id}}/params={}'
      },
      organisation_account: {
          home: 'organization_account/params={"id":"settings"}'
      },
      policies: {
          show: 'policies/{{record_id}}/params={}'
      },
      agreements: {
          show: 'agreements/{{record_id}}/params={}'
      },
      utility_subscriptions: {
          show: 'utility_bill_master/{{record_id}}/params={}'
      },
      users: {
          show: 'users/{{record_id}}/params={}'
      }
  }.with_indifferent_access.freeze

  def self.call(*route, variables: {})
    path = ROUTES.dig(*route)
    return nil if path.blank?

    variables.each do |key, value|
      path.gsub!("{{#{key}}}", value)
    end
    path
  end

end