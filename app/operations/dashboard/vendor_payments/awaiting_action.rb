class Dashboard::VendorPayments::AwaitingAction < Dashboard::VendorPayments::Base
  attr_accessor :result, :document_types

  has_scope :filter_inward_invoice_type

  def init
    self.document_types = {
      purchase_requests: false,
      purchase_orders: false,
      payment_tickets: false,
      non_po_invoices: false,
      po_invoices: false,
      vendors: false
    }

    user_roles = user.policy_user_roles.pluck(:user_role_id).uniq

    user_roles.each do |role_id|
      case role_id
      when UserRole.id_for(:admin)
        document_types.keys.map {|key| document_types[key] = true }
        break
      when UserRole.id_for(:purchase_request_reviewer)
        document_types[:purchase_requests] = true
      when UserRole.id_for(:purchase_order_reviewer)
        document_types[:purchase_orders] = true
      when UserRole.id_for(:invoice_reviewer)
        document_types[:po_invoices] = true
        document_types[:non_po_invoices] = true
      when UserRole.id_for(:bank_payment_request_reviewer)
        document_types[:payment_tickets] = true
      when UserRole.id_for(:vendor_reviewer)
        document_types[:vendors] = true
      end
    end

    self.result = []
  end

  def process
    if document_types[:purchase_orders]
      data = {
        title: "Purchase Orders",
        type: 'procurements',
        count: PurchaseOrder.awaiting_action_items(user).count,
        filters: [{filter_awaiting_approval: true}]
      }
      self.result.push data
    end

    if document_types[:payment_tickets]
      data = {
        title: "Payment Tickets",
        type: 'orders',
        count: BankPaymentRequest.awaiting_action_items(user).count,
        filters: [{filter_awaiting_approval: true}]
      }
      self.result.push data
    end

    if document_types[:purchase_requests]
      data = {
        title: "Purchase Requests",
        type: 'purchase_requests',
        count: PurchaseRequest.awaiting_action_items(user).count,
        filters: [{filter_awaiting_approval: true}]
      }
      self.result.push data
    end

    if document_types[:po_invoices] || document_types[:non_po_invoices]
      awaiting_invoices = Invoice.awaiting_action_items(user)

      if document_types[:po_invoices]
        data = {
          title: "PO Invoices",
          type: 'new_payment_invoices',
          count: apply_scopes(awaiting_invoices, {filter_inward_invoice_type: 'po_invoices'}).count,
          filters: [
            {filter_invoice_type: 'po_invoices'},
            {filter_awaiting_approval: true}
          ]
        }
        self.result.push data
      end

      if document_types[:non_po_invoices]
        data = {
          title: "Non PO Invoices",
          type: 'new_payment_invoices',
          count: apply_scopes(awaiting_invoices, {filter_inward_invoice_type: 'non_po_invoices'}).count,
          filters: [
            {filter_invoice_type: 'non_po_invoices'},
            {filter_awaiting_approval: true}
          ]
        }
        self.result.push data
      end
    end

    if document_types[:vendors]
      data = {
        title: "Vendors",
        type: 'vendors',
        count: YesBankVendor.awaiting_action_items(user).count,
        filters: [{filter_status_id: 'awaiting_approval'}]
      }
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