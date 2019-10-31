class Dashboard::VendorPayments::AwaitingAction < Dashboard::VendorPayments::Base
  attr_accessor :result, :document_types

  has_scope :filter_invoice_type

  def init
    self.document_types = {
      purchase_requests: false,
      purchase_orders: false,
      non_po_invoices: false,
      po_invoices: false,
      payment_tickets: false,
      vendors: false,
      grn: false,
      payment_agreements: false
    }

    if user.vendor_payments_admin?
      document_types.keys.map {|key| document_types[key] = true }
      unless user.company.procurement_enabled?
        document_types[:purchase_orders] = false
        document_types[:po_invoices] = false
        document_types[:non_po_invoices] = false
        document_types[:grn] = false
      end

      unless user.company.purchase_requisition_enabled?
        document_types[:purchase_requests] = false
      end

      unless user.company.vendor_empanelment_workflow_enabled?
        document_types[:vendors] = false
      end

      unless user.company.agreement_based_payment_system_enabled?
        document_types[:payment_agreements] = false
      end
    else
      user_roles = user.policy_user_roles.pluck(:user_role_id).uniq
      user_roles.each do |role_id|
        case role_id
        # when UserRole.id_for(:admin) ######## Admin role removed as PUR doesn't have it
        #   document_types.keys.map {|key| document_types[key] = true }
        #   break
        when UserRole.id_for(:purchase_request_reviewer)
          document_types[:purchase_requests] = true
        when UserRole.id_for(:purchase_order_reviewer)
          document_types[:purchase_orders] = true
        when UserRole.id_for(:non_po_invoice_reviewer)
          document_types[:non_po_invoices] = true
        when UserRole.id_for(:po_invoice_reviewer)
          document_types[:po_invoices] = true
        when UserRole.id_for(:goods_receiver)
          document_types[:grn] = true
        when UserRole.id_for(:bank_payment_request_reviewer)
          document_types[:payment_tickets] = true
        when UserRole.id_for(:vendor_reviewer)
          if user.company.vendor_empanelment_workflow_enabled?
            document_types[:vendors] = true
          end
        when UserRole.id_for(:payment_agreement_reviewer)
          document_types[:payment_agreements] = true
        end
      end
    end

    unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
      document_types[:grn] = false
    end

    self.result = []
  end

  def process
    if document_types[:purchase_requests]
      purchase_requests = PurchaseRequest.awaiting_action_items(user)
      if params[:filter_date_from].present? || params[:filter_date_to].present?
        purchase_requests = purchase_requests.filter_by_date_range(params[:filter_date_from], params[:filter_date_to])
      end
      data = {
        title: "Purchase Requests",
        type: 'purchase_requests',
        count: purchase_requests.count,
        filters: [{filter_awaiting_approval: '1'}]
      }

      if params[:filter_date_from].present?
        filter_data = {'filter_by_date_range[from]': params[:filter_date_from]}
        data[:filters].push(filter_data)
      end

      if params[:filter_date_to].present?
        filter_data = {'filter_by_date_range[to]': params[:filter_date_to]}
        data[:filters].push(filter_data)
      end
      self.result.push data
    end


    if document_types[:purchase_orders]
      purchase_orders = PurchaseOrder.awaiting_action_items(user)
      if params[:filter_date_from].present?
        purchase_orders = purchase_orders.filter_creation_date_from(params[:filter_date_from])
      end

      if params[:filter_date_to].present?
        purchase_orders = purchase_orders.filter_creation_date_to(params[:filter_date_to])
      end
      data = {
        title: "Purchase Orders",
        type: 'purchase_orders',
        count: purchase_orders.count,
        filters: [{filter_status: 'awaiting_approval'}]
      }

      if params[:filter_date_from].present?
        filter_data = {filter_creatino_date_from: params[:filter_creation_date_from]}
        data[:filters].push(filter_data)
      end

      if params[:filter_date_to].present?
        filter_data = {filter_creatino_date_to: params[:filter_creation_date_to]}
        data[:filters].push(filter_data)
      end
      self.result.push data
    end


    if document_types[:po_invoices] || document_types[:non_po_invoices]
      awaiting_invoices = Invoice.awaiting_action_items(user)

      if document_types[:po_invoices]

        po_invoices = awaiting_invoices.filter_invoice_type('po_invoice')

        if params[:filter_date_from].present? || params[:filter_date_to].present?
          po_invoices = po_invoices.filter_creation_date(params[:filter_date_from], params[:filter_date_to])
        end
        data = {
          title: "PO Invoices",
          type: 'new_payment_invoices',
          count: po_invoices.count,
          filters: [
            {filter_invoice_type: 'po_invoice'},
            {filter_awaiting_approval: true}
          ]
        }

        if params[:filter_date_from].present?
          filter_data = {'filter_creation_date[from]': params[:filter_date_from]}
          data[:filters].push(filter_data)
        end

        if params[:filter_date_to].present?
          filter_data = {'filter_creation_date[to]': params[:filter_date_to]}
          data[:filters].push(filter_data)
        end

        self.result.push data
      end

      if document_types[:non_po_invoices]
        non_po_invoices = awaiting_invoices.filter_invoice_type('non_po_invoice')

        if params[:filter_date_from].present? || params[:filter_date_to].present?
          non_po_invoices = non_po_invoices.filter_creation_date(params[:filter_date_from], params[:filter_date_to])
        end

        data = {
          title: "Non PO Invoices",
          type: 'new_payment_invoices',
          count: non_po_invoices.count,
          filters: [
            {filter_invoice_type: 'non_po_invoice'},
            {filter_awaiting_approval: true}
          ]
        }

        if params[:filter_date_from].present?
          filter_data = {'filter_creation_date[from]': params[:filter_date_from]}
          data[:filters].push(filter_data)
        end

        if params[:filter_date_to].present?
          filter_data = {'filter_creation_date[to]': params[:filter_date_to]}
          data[:filters].push(filter_data)
        end
        self.result.push data
      end
    end

    if document_types[:payment_tickets]
      payment_tickets = BankPaymentRequest.awaiting_action_items(user)

      if params[:filter_date_from].present? || params[:filter_date_to].present?
        payment_tickets = payment_tickets.filter_date(params[:filter_date_from], params[:filter_date_to])
      end

      data = {
        title: "Payment Tickets",
        type: 'orders',
        count: payment_tickets.count,
        filters: [{filter_status: 'awaiting_approval'}]
      }

      if params[:filter_date_from].present?
        filter_data = {'filter_date[from]': params[:filter_date_from]}
        data[:filters].push(filter_data)
      end

      if params[:filter_date_to].present?
        filter_data = {'filter_date[to]': params[:filter_date_to]}
        data[:filters].push(filter_data)
      end

      self.result.push data
    end
    
    if document_types[:vendors]
      vendors = YesBankVendor.awaiting_action_items(user)

      if params[:filter_date_from].present? || params[:filter_date_to].present?
        vendors = vendors.filter_creation_date(params[:filter_date_from], params[:filter_date_to])
      end

      data = {
        title: "Vendors",
        type: 'vendor',
        count: vendors.count,
        filters: [{filter_status_id: 'awaiting_approval'}]
      }

      if params[:filter_date_from].present?
        filter_data = {'filter_creation_date[from]': params[:filter_date_from]}
        data[:filters].push(filter_data)
      end

      if params[:filter_date_to].present?
        filter_data = {'filter_creation_date[to]': params[:filter_date_to]}
        data[:filters].push(filter_data)
      end

      self.result.push data
    end  

    if document_types[:grn]
      params[:filter_procurement_type] = "purchase_order"
      # params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment)]
      params[:filter_status_tags] = [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)]

      params[:filter_creation_date_from] = params[:filter_date_from] if params[:filter_date_from].present?
      params[:filter_creation_date_to] = params[:filter_date_to] if params[:filter_date_to].present?
      params[:filter_awaiting_action] = true

      procurements = Procurements::Grn::Pending::Index.(user, params)
      data = {
        title: "Receipt Note",
        type: 'receive',
        count: procurements.count,
        # filters: [{filter_status_tags: [7]}]
        filters: [{filter_status_tags: [StatusTag.id_for(:receiving_shipment), StatusTag.id_for(:po_approved), StatusTag.id_for(:po_sent)], filter_awaiting_action: true}]
      }

      if params[:filter_date_from].present?
        filter_data = {filter_creatino_date_from: params[:filter_creation_date_from]}
        data[:filters].push(filter_data)
      end

      if params[:filter_date_to].present?
        filter_data = {filter_creatino_date_to: params[:filter_creation_date_to]}
        data[:filters].push(filter_data)
      end
      self.result.push data
    end

    if document_types[:payment_agreements]
      payment_agreements = PaymentAgreement.awaiting_action_items(user)
      if params[:filter_date_from].present? || params[:filter_date_to].present?
        payment_agreements = payment_agreements.filter_by_date_range(params[:filter_date_from], params[:filter_date_to])
      end
      data = {
        title: "Payment Agreements",
        type: 'agreements',
        count: payment_agreements.count,
        filters: [{filter_by_status_id: 'awaiting_approval'}]
      }

      if params[:filter_date_from].present?
        filter_data = {'filter_by_date_range[from]': params[:filter_date_from]}
        data[:filters].push(filter_data)
      end

      if params[:filter_date_to].present?
        filter_data = {'filter_by_date_range[to]': params[:filter_date_to]}
        data[:filters].push(filter_data)
      end
      self.result.push data
    end

  end

  def success
    params[:result] = self.result
    Dashboard::VendorPayments::AwaitingAction::DashboardPresenter.new(user, params, messages)
  end


  class Dashboard::VendorPayments::AwaitingAction::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :result

    def init
      self.result = params[:result]
    end
  end
end