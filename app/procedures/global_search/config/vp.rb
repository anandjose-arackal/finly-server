class GlobalSearch::Config::Vp

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
          :rejected, :failed, :cancelled, :expired
      ].map { |i| i.to_s.humanize }.uniq
  }.freeze

  DOCUMENT_PERMISSIONS = {
      purchase_requests: {
          index: PurchaseRequest,
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
          index: PurchaseRequest,
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
          index: PurchaseRequest,
          features: [:procurement],
          permissions: Docs::P2P::Invoices::Index.permissions,
          category: :transactions,
          route: 'procure_invoice/{{record_id}}/params={"procurement_id":"{{parent_id}}","procurement_type":"{{parent_type}}"}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      payment_tickets: {
          index: PurchaseRequest,
          permissions: Docs::PaymentTickets::Index.permissions,
          category: :transactions,
          route: 'orders/{{record_id}}/params={}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      payments: {
          index: PurchaseRequest,
          permissions: Docs::PaymentTickets::Payments::Index.permissions,
          category: :transactions,
          route: 'orders/{{parent_id}}/params={}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      utility_bills: {
          index: PurchaseRequest,
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
          index: PurchaseRequest,
          permissions: Masters::Vendors::Index.permissions,
          category: :masters,
          route: 'vendor/{{record_id}}/params={}',
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      items: {
          index: PurchaseRequest,
          permissions: Masters::Items::Index.permissions,
          category: :masters,
          route: 'inventory/{{record_id}}/params={}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:category_name, :status_name]
          }
      },
      categories: {
          index: PurchaseRequest,
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      policies: {
          index: PurchaseRequest,
          permissions: [:admin],
          category: :masters,
          route: 'policies/{{record_id}}/params={}',
          layout: {
              fixed_left: [:policy_name],
              fixed_right: []
          }
      },
      departments: {
          index: PurchaseRequest,
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      locations: {
          index: PurchaseRequest,
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      cost_centers: {
          index: PurchaseRequest,
          permissions: [:admin],
          category: :masters,
          route: 'organization_account/params={"id":"settings"}',
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: []
          }
      },
      payment_agreements: {
          index: PurchaseRequest,
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
          index: PurchaseRequest,
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
          index: PurchaseRequest,
          permissions: [:admin],
          category: :masters,
          route: 'users/{{record_id}}/params={}',
          layout: {
              fixed_left: [:user_name, :user_email],
              fixed_right: [:status_name]
          }
      }
  }.freeze

end