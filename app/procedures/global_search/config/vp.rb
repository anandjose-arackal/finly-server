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
          route: UrlBuilder.(:purchase_requests, :show),
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      purchase_orders: {
          index: PurchaseOrder,
          features: [:procurement],
          permissions: Docs::P2P::PurchaseOrders::Index.permissions,
          category: :transactions,
          route: UrlBuilder.(:purchase_orders, :show, variables: {procurement_id: '{{parent_id}}', procurement_type: 'po'}),
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      invoices: {
          index: Invoice,
          features: [:procurement],
          permissions: Docs::P2P::Invoices::Index.permissions,
          category: :transactions,
          route: UrlBuilder.(:invoices, :show, variables: {procurement_id: '{{parent_id}}', procurement_type: "{{parent_type}}"}),
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      payment_tickets: {
          index: BankPaymentRequest,
          permissions: Docs::PaymentTickets::Index.permissions,
          category: :transactions,
          route: UrlBuilder.(:payment_tickets, :show),
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      payments: {
          index: Payment,
          permissions: Docs::PaymentTickets::Payments::Index.permissions,
          category: :transactions,
          route: UrlBuilder.(:payments, :show),
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      utility_bills: {
          index: BbpsBill,
          features: [:procurement],
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :transactions,
          route: UrlBuilder.(:utility_bills, :show),
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      vendors: {
          index: YesBankVendor,
          permissions: Masters::Vendors::Index.permissions,
          category: :masters,
          route: UrlBuilder.(:vendors, :show),
          layout: {
              fixed_left: [:vendor_name, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      items: {
          index: Item,
          permissions: Masters::Items::Index.permissions,
          category: :masters,
          route: UrlBuilder.(:items, :show),
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:category_name, :status_name]
          }
      },
      categories: {
          index: Category,
          permissions: [:admin],
          category: :masters,
          route: UrlBuilder.(:organisation_account, :home),
          layout: {
              fixed_left: [:category_name, :category_code],
              fixed_right: []
          }
      },
      policies: {
          index: Policy,
          permissions: [:admin],
          category: :masters,
          route: UrlBuilder.(:policies, :show),
          layout: {
              fixed_left: [:policy_name],
              fixed_right: []
          }
      },
      departments: {
          index: Department,
          permissions: [:admin],
          category: :masters,
          route: UrlBuilder.(:organisation_account, :home),
          layout: {
              fixed_left: [:department_name, :department_code],
              fixed_right: []
          }
      },
      locations: {
          index: BranchLocation,
          permissions: [:admin],
          category: :masters,
          route: UrlBuilder.(:organisation_account, :home),
          layout: {
              fixed_left: [:location_name, :location_code],
              fixed_right: []
          }
      },
      cost_centers: {
          index: CostCenter,
          permissions: [:admin],
          category: :masters,
          route: UrlBuilder.(:organisation_account, :home),
          layout: {
              fixed_left: [:cost_center_name, :cost_center_code],
              fixed_right: []
          }
      },
      payment_agreements: {
          index: PaymentAgreement,
          features: :agreement_based_payment_system,
          permissions: Docs::P2P::Agreements::Index.permissions,
          category: :masters,
          route: UrlBuilder.(:agreements, :show),
          layout: {
              fixed_left: [:description, :sequence_id],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      utility_subscriptions: {
          index: BbpsBillerSubscription,
          features: :utility_bills_enabled,
          permissions: Docs::UtilityBills::Subscriptions::Index.permissions,
          category: :masters,
          route: UrlBuilder.(:utility_subscriptions, :show),
          layout: {
              fixed_left: [:description, :sequence_id, :vendor_name],
              fixed_right: [:created_by_name, :created_by_email, :status_name]
          }
      },
      users: {
          index: User,
          permissions: [:admin],
          category: :masters,
          route: UrlBuilder.(:users, :show),
          layout: {
              fixed_left: [:user_name, :user_email],
              fixed_right: [:status_name]
          }
      }
  }.freeze

end