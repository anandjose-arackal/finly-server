class GlobalSearch::Config < Transactions::API

  pass :generate_token
  pass :generate_filters

  def generate_token(context, current_user:, **)
    context[:token] = GlobalSearch::AccessControl.config_for(current_user)
    context[:expires_in] = GlobalSearch::AccessControl::TOKEN_EXPIRY.to_i
  end

  def generate_filters(context, current_user:, **)
    context[:documents] = {transactions: [], masters: []}

    GlobalSearch::Config::Vp::DOCUMENT_PERMISSIONS.each do |document, config|
      if authorized?(current_user, config)
        context[:documents][config[:category]] << {
            document_type: config[:index].searchkick_api.record_type,
            route: config[:route],
            layout: config[:layout]
        }
      end
    end

    context[:documents][:masters] = context[:documents][:masters].sort_by { |document| document[:document_type] }
    context[:documents][:transactions] = context[:documents][:transactions].sort_by { |document| document[:document_type] }
    context[:indicator_map] = GlobalSearch::Config::Vp::STATUS_INDICATORS

    true
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

  # DOCUMENT_PERMISSIONS = {
  #     purchase_requests: {
  #         features: [:procurement, :purchase_requisition_system],
  #         permissions: Docs::P2P::PurchaseRequests::Index.permissions,
  #         category: :transactions,
  #         route: 'purchase_request/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     purchase_orders: {
  #         features: [:procurement],
  #         permissions: Docs::P2P::PurchaseOrders::Index.permissions,
  #         category: :transactions,
  #         route: 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}',
  #         layout: {
  #             fixed_left: [:vendor_name, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     invoices: {
  #         features: [:procurement],
  #         permissions: Docs::P2P::Invoices::Index.permissions,
  #         category: :transactions,
  #         route: 'procure_invoice/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}',
  #         layout: {
  #             fixed_left: [:vendor_name, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     payment_tickets: {
  #         permissions: Docs::PaymentTickets::Index.permissions,
  #         category: :transactions,
  #         route: 'orders/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     payments: {
  #         permissions: Docs::PaymentTickets::Payments::Index.permissions,
  #         category: :transactions,
  #         route: 'orders/{{parent_id}}/params={}',
  #         layout: {
  #             fixed_left: [:vendor_name, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     utility_bills: {
  #         features: [:procurement],
  #         permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
  #         category: :transactions,
  #         route: 'utility_bill/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:vendor_name, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     vendors: {
  #         permissions: Masters::Vendors::Index.permissions,
  #         category: :masters,
  #         route: 'vendor/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:vendor_name, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     items: {
  #         permissions: Masters::Items::Index.permissions,
  #         category: :masters,
  #         route: 'inventory/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: [:category_name, :status_name]
  #         }
  #     },
  #     categories: {
  #         permissions: [:admin],
  #         category: :masters,
  #         route: 'organization_account/params={"id":"settings"}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: []
  #         }
  #     },
  #     policies: {
  #         permissions: [:admin],
  #         category: :masters,
  #         route: 'policies/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:policy_name],
  #             fixed_right: []
  #         }
  #     },
  #     departments: {
  #         permissions: [:admin],
  #         category: :masters,
  #         route: 'organization_account/params={"id":"settings"}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: []
  #         }
  #     },
  #     locations: {
  #         permissions: [:admin],
  #         category: :masters,
  #         route: 'organization_account/params={"id":"settings"}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: []
  #         }
  #     },
  #     cost_centers: {
  #         permissions: [:admin],
  #         category: :masters,
  #         route: 'organization_account/params={"id":"settings"}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: []
  #         }
  #     },
  #     payment_agreements: {
  #         features: :agreement_based_payment_system,
  #         permissions: Docs::P2P::Agreements::Index.permissions,
  #         category: :masters,
  #         route: 'agreements/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     utility_subscriptions: {
  #         features: :utility_bills_enabled,
  #         permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
  #         category: :masters,
  #         route: 'utility_bill_master/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:description, :sequence_id],
  #             fixed_right: [:created_by_name, :created_by_email, :status_name]
  #         }
  #     },
  #     users: {
  #         permissions: [:admin],
  #         category: :masters,
  #         route: 'users/{{record_id}}/params={}',
  #         layout: {
  #             fixed_left: [:user_name, :user_email],
  #             fixed_right: [:status_name]
  #         }
  #     }
  # }.freeze

end