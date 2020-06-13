class Dashboard::P2P::AwaitingApproval < Dashboard::IndexCard

  skip_admin!

  TILES = [
      {
          title: "Purchase Requests",
          path: "purchase_requests",
          status_id: PurchaseRequestStatus::GROUP_AWAITING_APPROVAL,
          model: PurchaseRequest,
          filters: {
              policy: :policy_id,
              location: :items_delivery_location_id,
              department: :items_department_id,
              cost_center: :items_cost_center_id
          },
          permission: -> (context, current_user:, **) {
            current_user.company.purchase_requisition_enabled? and current_user.has_permission?(:purchase_request_reviewer)
          }
      },
      {
          title: "Purchase Orders",
          path: "purchase_orders",
          status_id: PurchaseOrderStatus::GROUP_AWAITING_APPROVAL,
          model: PurchaseOrder,
          filters: {
              policy: :policy_id,
              location: :delivery_location_id,
              department: :items_department_id,
              cost_center: :items_cost_center_id
          },
          permission: -> (context, current_user:, **) {
            current_user.company.procurement_enabled? and current_user.has_permission?(:purchase_order_reviewer)
          }
      },
      {
          title: "Invoices",
          path: "invoices",
          status_id: InwardInvoiceStatus::GROUP_AWAITING_APPROVAL,
          model: Invoice,
          filters: {
              policy: :policy_id,
              location: :delivery_location_id,
              department: :items_department_id,
              cost_center: :items_cost_center_id
          },
          permission: -> (context, current_user:, **) {
            current_user.company.procurement_enabled? and current_user.has_permission?([:non_po_invoice_reviewer, :po_invoice_reviewer, :agreement_invoice_reviewer])
          }
      },
      {
          title: "Utility Bills",
          path: "utility_bills",
          status_id: BbpsBillStatus::GROUP_AWAITING_APPROVAL,
          model: BbpsBill,
          filters: {
              policy: :policy_id,
              location: :location_id,
              department: :department_id,
              cost_center: :cost_center_id
          },
          permission: -> (context, current_user:, **) {
            current_user.company.utility_bills_enabled? and current_user.has_permission?(:utility_bill_reviewer)
          }
      },
      {
          title: "Payment Tickets",
          path: "payment_tickets",
          status_id: BankPaymentRequestStatus::GROUP_AWAITING_APPROVAL,
          model: BankPaymentRequest,
          filters: {
              policy: :policy_id,
          },
          permission: -> (context, current_user:, **) {
            current_user.has_permission?(:bank_payment_request_reviewer)
          }
      },
      {
          title: "Vendor",
          path: "vendors",
          status_id: VendorStatus::GROUP_AWAITING_APPROVAL,
          model: YesBankVendor,
          filters: {
              policy: :policy_id,
          },
          permission: -> (context, current_user:, **) {
            current_user.company.vendor_empanelment_workflow_enabled? and current_user.has_permission?(:vendor_reviewer)
          }
      },
      {
          title: "Agreements",
          path: "agreements",
          status_id: PaymentAgreementStatus::GROUP_AWAITING_APPROVAL,
          model: PaymentAgreement,
          filters: {
              policy: :policy_id,
          },
          permission: -> (context, current_user:, **) {
            current_user.company.agreement_based_payment_system_enabled? and current_user.has_permission?(:payment_agreement_reviewer)
          }
      },
      {
          title: "Utility Bill Subscriptions",
          path: "utility_subscriptions",
          status_id: BbpsBillerSubscriptionStatus::GROUP_AWAITING_APPROVAL,
          model: BbpsBillerSubscription,
          filters: {
              policy: :policy_id,
              location: :location_id,
              department: :department_id,
              cost_center: :cost_center_id
          },
          permission: -> (context, current_user:, **) {
            current_user.company.utility_bills_enabled? and current_user.has_permission?(:utility_bill_master_reviewer)
          }
      }
  ]

  # def build_personal_row(context, current_user:, **)
  #   return unless current_user.has_permission?(self.class.permissions) or current_user.vp_admin_or_auditor?
  #   return if self.class.skip_personal?
  #
  #   context[:data] << build_tiles(context, filter_created_by: true)
  # end

  def build_tiles(context, filter_created_by: nil)
    tiles = []
    TILES.each do |tile|
      next if tile[:permission] and not tile[:permission].call(context, **context)

      query = {}
      rule = build_rule(context, tile, filter_created_by: false)
      query = rule.as_ransack if rule.present?

      count = tile[:model].ransack(query).result.awaiting_action_items(context[:current_user]).count
      tiles << build_tile(count: count, rule: rule, title: tile[:title], path: tile[:path], status_id: PurchaseRequestStatus::GROUP_AWAITING_APPROVAL)
    end
    tiles
  end

  def build_rule(context, tile, filter_created_by: false)
    rule = []
    params = context[:params]
    if filter_created_by
      rule << Rules::Builder[self.class.created_by].eq_any(value: context[:current_user].id).with_meta([{id: context[:current_user].id, name: context[:current_user].name}])
    end
    if params[:filter_policy].present? and tile[:filters][:policy].present?
      rule << Rules::Builder[self.class.policy].eq_any(value: params[:filter_policy])
    end
    if (params[:filter_department].present? or params[:filter_sub_department].present?) and tile[:filters][:department].present?
      department_id = params[:filter_sub_department] or params[:filter_department]
      rule << Rules::Builder[self.class.department].eq_any(value: department_id)
    end
    if params[:filter_location].present? and tile[:filters][:location].present?
      rule << Rules::Builder[self.class.location].eq_any(value: params[:filter_location])
    end
    if params[:filter_cost_center].present? and tile[:filters][:cost_center].present?
      rule << Rules::Builder[self.class.cost_center].eq_any(value: params[:filter_cost_center])
    end
    attribute_rule = rule.shift
    return attribute_rule if rule.blank? or attribute_rule.blank?

    attribute_rule.and(*rule)
  end

  def build_tile(count:, rule:, title:, path:, status_id:)
    {
        title: title,
        count: count,
        url: build_path(rule, 'Awaiting Approval', path, status_id)
    }
  end

  def build_path(rule, label, path, status_id)
    params = {
        filter_status: {_id: status_id&.to_s, identifier: label},
        id: self.class.path
    }
    if rule.present?
      filter = rule.as_ransack
      params[:input_filters] = {advanced: [filter[:g][:'0']]}
    end
    "#{path}/params=#{params.to_json}"
  end

end