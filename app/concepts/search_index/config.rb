class SearchIndex::Config < Transactions::API

  # utility subscriptions: utility_bill_master/:id/params={}
  DOCUMENT_PERMISSIONS = {
      purchase_requests: {
          features: [:procurement, :purchase_requisition_system],
          permissions: Docs::P2P::PurchaseRequests::Index.permissions,
          category: :transactions,
          route: 'purchase_request/{{record_id}}/params={}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      purchase_orders: {
          features: [:procurement],
          permissions: Docs::P2P::PurchaseOrders::Index.permissions,
          category: :transactions,
          route: 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      invoices: {
          features: [:procurement],
          permissions: Docs::P2P::Invoices::Index.permissions,
          category: :transactions,
          route: 'procure_purchase_order/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      payments: {
          permissions: Docs::PaymentTickets::Payments::Index.permissions,
          category: :transactions,
          route: 'orders/{{parent_id}}/params={}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      utility_bills: {
          features: [:procurement],
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :transactions,
          route: 'utility_bill/{{record_id}}/params={}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      vendors: {
          permissions: Masters::Vendors::Index.permissions,
          category: :masters,
          route: 'vendor/{{record_id}}/params={}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      items: {
          permissions: Masters::Items::Index.permissions,
          category: :masters,
          route: 'inventory/{{record_id}}/params={}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:category_name, :status_name]
          }
      },
      categories: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      policies: {
          permissions: [:admin],
          category: :masters,
          route: 'policies/{{record_id}}/params={}',
          layout: {
              fixed_left: [:policy],
              fixed_right: []
          }
      },
      departments: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      locations: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      cost_centers: {
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      payment_agreements: {
          features: :agreement_based_payment_system,
          permissions: Docs::P2P::Agreements::Index.permissions,
          category: :masters,
          route: 'agreements/{{record_id}}/params={}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      utility_subscriptions: {
          features: :utility_bills_enabled,
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :masters,
          route: 'utility_bill_master/{{record_id}}/params={}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      users: {
          permissions: [:admin],
          category: :masters,
          route: 'users/{{record_id}}/params={}',
          layout: {
              fixed_left: [:name, :email],
              fixed_right: [:status_name]
          }
      }
  }.freeze

  STATUS_INDICATORS = {
      info: [
          :draft, :retracted, :deactivated, :open, :voided, :inactive,
          :initiated, :order_initiated, :po_created, :partially_closed,
          :to_be_processed, :pending, :po_processing, :saved,
          :pending_approval, :pending_retry, :creation_in_progress,
          :submitted, :partially_adjusted, :unadjusted
      ].map { |i| i.to_s.humanize }.uniq,
      warning: [
          :awaiting_approval, :processing,
          :scheduled, :possible_failure, :pending_credit,
          :unapprove,
      ].map { |i| i.to_s.humanize }.uniq,
      success: [
          :approved, :auto_approved, :active,
          :paid, :payment_ticket_created, :payment_initiated,
          :payment_ticket_deleted, :completed,
          :reactivated, :closed, :invoice_created, :payment_ticket_created,
          :unpaid, :partially_paid, :sent_to_vendor,
          :po_revised, :vendor_confirmed,
          :credited, :pending_credit, :adjusted,
      ].map { |i| i.to_s.humanize }.uniq,
      danger: [
          :rejected, :failed, :cancelled
      ].map { |i| i.to_s.humanize }.uniq
  }.freeze

  pass :generate_token
  pass :generate_filters

  def generate_token(context, current_user:, **)
    context[:token] = current_user.build_search_index_token
    context[:expires_in] = SearchIndex::Concerns::AccessControl::TOKEN_EXPIRY.to_i
  end

  def generate_filters(context, current_user:, **)
    context[:documents] = {transactions: [], masters: []}
    DOCUMENT_PERMISSIONS.each_pair do |document, config|
      if authorized?(current_user, config)
        context[:documents][config[:category]] << {
            document_type: document,
            route: config[:route],
            layout: config[:layout]
        }
      end
    end
    context[:documents][:masters] = context[:documents][:masters].sort_by { |document| document[:document_type] }
    context[:documents][:transactions] = context[:documents][:transactions].sort_by { |document| document[:document_type] }
    context[:indicator_map] = STATUS_INDICATORS

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