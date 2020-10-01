class SearchIndex::GenerateToken < Transactions::API

  DOCUMENT_PERMISSIONS = {
      purchase_requests: {
          features: [:procurement, :purchase_requisition_system],
          permissions: Docs::P2P::PurchaseRequests::Index.permissions,
          category: :transactions
      },
      purchase_orders: {
          features: [:procurement],
          permissions: Docs::P2P::PurchaseOrders::Index.permissions,
          category: :transactions
      },
      invoices: {
          features: [:procurement],
          permissions: Docs::P2P::Invoices::Index.permissions,
          category: :transactions
      },
      payments: {
          permissions: Docs::PaymentTickets::Payments::Index.permissions,
          category: :transactions
      },
      utility_bills: {
          features: [:procurement],
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :transactions
      },
      vendors: {
          permissions: Masters::Vendors::Index.permissions,
          category: :masters
      },
      items: {
          permissions: Masters::Items::Index.permissions,
          category: :masters
      },
      categories: {
          permissions: [:admin],
          category: :masters
      },
      policies: {
          permissions: [:admin],
          category: :masters
      },
      departments: {
          permissions: [:admin],
          category: :masters
      },
      locations: {
          permissions: [:admin],
          category: :masters
      },
      cost_centers: {
          permissions: [:admin],
          category: :masters
      },
      payment_agreements: {
          features: :agreement_based_payment_system,
          permissions: Docs::P2P::Agreements::Index.permissions,
          category: :masters
      },
      utility_subscriptions: {
          features: :utility_bills_enabled,
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :masters
      },
      users: {
          permissions: [:admin],
          category: :masters
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
      context[:documents][config[:category]] << document if authorized?(current_user, config)
    end
    context[:documents][:masters] = context[:documents][:masters].sort_by {|document| document}
    context[:documents][:transactions] = context[:documents][:transactions].sort_by {|document| document}

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