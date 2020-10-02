class SearchIndex::GenerateToken < Transactions::API

  # utility subscriptions: utility_bill_master/:id/params={}
  DOCUMENT_PERMISSIONS = {
      purchase_requests: {
          features: [:procurement, :purchase_requisition_system],
          permissions: Docs::P2P::PurchaseRequests::Index.permissions,
          category: :transactions,
          route: 'purchase_request/{{record_id}}/params={}'
      },
      purchase_orders: {
          features: [:procurement],
          permissions: Docs::P2P::PurchaseOrders::Index.permissions,
          category: :transactions,
          route: 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}'
      },
      invoices: {
          features: [:procurement],
          permissions: Docs::P2P::Invoices::Index.permissions,
          category: :transactions,
          route: 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}'
      },
      payments: {
          permissions: Docs::PaymentTickets::Payments::Index.permissions,
          category: :transactions,
          route: 'orders/{{parent_id}}/params={}'
      },
      utility_bills: {
          features: [:procurement],
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :transactions,
          route: 'utility_bill/{{record_id}}/params={}'
      },
      vendors: {
          permissions: Masters::Vendors::Index.permissions,
          category: :masters,
          route: 'vendor/{{record_id}}/params={}'
      },
      items: {
          permissions: Masters::Items::Index.permissions,
          category: :masters,
          route: 'inventory/{{record_id}}/params={}'
      },
      categories: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}'
      },
      policies: {
          permissions: [:admin],
          category: :masters,
          route: 'policies/{{record_id}}/params={}'
      },
      departments: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}'
      },
      locations: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}'
      },
      cost_centers: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}'
      },
      payment_agreements: {
          features: :agreement_based_payment_system,
          permissions: Docs::P2P::Agreements::Index.permissions,
          category: :masters,
          route: 'agreements/{{record_id}}/params={}'
      },
      utility_subscriptions: {
          features: :utility_bills_enabled,
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :masters,
          route: 'utility_bill_master/{{record_id}}/params={}'
      },
      users: {
          permissions: [:admin],
          category: :masters,
          route: 'users/{{record_id}}/params={}'
      }
  }

  pass :generate_token
  pass :generate_filters

  def generate_token(context, current_user:, **)
    context[:token] = current_user.build_search_index_token
  end

  def generate_filters(context, current_user:, **)
    context[:documents] = {transactions: [], masters: []}
    DOCUMENT_PERMISSIONS.each_pair do |document, config|
      context[:documents][config[:category]] << {document_type: document, route: config[:route]} if authorized?(current_user, config)
    end
    context[:documents][:masters] = context[:documents][:masters].sort_by {|document| document[:document_type]}
    context[:documents][:transactions] = context[:documents][:transactions].sort_by {|document| document[:document_type]}

    true
  end

  def authorized?(current_user, config)
    return false unless current_user.present?
    return false unless config[:permissions].blank? or current_user.has_permission?(config[:permissions])
    return false unless company_subscribed?(current_user, config)

    true
  end

  def company_subscribed?(user, config)
    return true unless config[:features].present?

    config[:features] = [config[:features]] unless config[:features].respond_to?(:each)

    config[:features].each do |feature|
      return false unless !!user.company.feature_subscription.send(feature)
    end

    true
  end

end