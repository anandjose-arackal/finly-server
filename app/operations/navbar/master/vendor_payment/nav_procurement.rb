class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs,
      [
          :dashboard,
          {procure: [:po_initiator, :po_awaiting_approval, :po_team, :po_policy, :po_company]},
          {shipments: [:shipments_pending, :shipments_history]},
          {payables: [:unbilled_items, :po_advances, :invoices, :payment_tickets]},
          {manage: [:manage_vendors, :manage_item_master, :manage_rate_contracts]},
          {create: [:create_purchase_order, :create_po_invoice, :create_non_po_invoice, :create_payment_ticket]}
      ]
  )
  register_structure(
      :cog,
      [:attachments]
  )

  def self.accept?
    return false unless RequestStoreUtil.current_user.user_panel_subscription.yes_bank_account_transfer
    return false unless RequestStoreUtil.current_company&.feature_subscription&.procurement
    true
  end

  def dashboard
    {name: 'Dashboard', id: 'dashboard', url: 'dashboard'}
  end

  def procure
    {name: 'Procure', id: 'procure', url: 'procure'}
  end

  def po_initiator
    if is_purchase_order_initiator?
      {name: 'Your Purchase Orders', id: 'purchase_orders', url: 'purchase_orders'}
    end
  end

  def po_awaiting_approval
    if is_purchase_request_reviewer? || user.vendor_payments_admin?
      {name: 'PO Awaiting Approval', id: 'purchase_orders', url: 'purchase_orders/vendors'}
    end
  end

  def po_team
    {name: 'PO Awaiting Approval', id: 'purchase_orders', url: 'purchase_orders/vendors'}
  end

  def po_policy
    {name: 'PO Awaiting Approval', id: 'purchase_orders', url: 'purchase_orders/vendors'}
  end

  def po_company
    {name: 'PO Awaiting Approval', id: 'purchase_orders', url: 'purchase_orders/vendors'}
  end

  def shipments
    {name: 'Shipments', id: 'po_shipments', url: 'purchase_orders/shipments'}
  end

  def shipments_pending
    {name: 'Pending Shipments', id: 'pending_po_shipments', url: 'purchase_orders/shipments'}
  end

  def shipments_history
    {name: 'Pending Shipments', id: 'pending_po_shipments', url: 'purchase_orders/shipments'}
  end

  def payables
    {name: 'Payables', id: 'payables', url: 'payables'}
  end

  def unbilled_items
    {name: 'Unbilled Items', id: 'payables_unbilled_items', url: 'payables/unbilled_items'}
  end

  def po_advances
    {name: 'PO Advances', id: 'payables_po_advances', url: 'payables/po_advances'}
  end

  def invoices
    {name: 'Invoices', id: 'payables_invoices', url: 'payables/invoices'}
  end

  def payment_tickets
    {name: 'Payment Tickets', id: 'payables_payment_tickets', url: 'payables/payment_tickets'}
  end

  def manage
    {name: 'Manage', id: 'manage', url: 'manage'}
  end

  def manage_vendors
    if user.is_vendor_manger? || user.is_vendor_initiator? || user.is_vendor_reviewer? || user.vendor_payments_admin?
      {name: 'Vendors', id: 'manage_vendors', url: 'manage/vendors'}
    end 
  end

  def manage_item_master
    if user.is_item_master_manager? || user.vendor_payments_admin?
      {name: 'Item Master', id: 'manage_item_master', url: 'manage/item_master'}
    end
  end

  def manage_rate_contracts
    if user.is_item_master_manager? || user.vendor_payments_admin?
      {name: 'Rate Contracts', id: 'manage_rate_contracts', url: 'manage/rate_contracts'}
    end
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    if user.is_purchase_order_initiator? || user.vendor_payments_admin?
      {name: 'New Purchase Order', id: 'create_purchase_order', url: 'purchase_orders/new'}
    end
  end

  def create_po_invoice
    if user.is_invoice_initiator? || user.vendor_payments_admin?
      {name: 'New PO Invoice', id: 'create_po_invoice', url: 'purchase_orders/invoices/new'}
    end
  end

  def create_non_po_invoice
    if user.is_invoice_initiator? || user.vendor_payments_admin?
      {name: 'New Non PO Invoice', id: 'create_non_po_invoice', url: 'non_po_invoices/new'}
    end
  end

  def create_payment_ticket
    if user.is_bank_payment_request_initiator? || user.vendor_payments_admin?
      {name: 'New Payment Ticket', id: 'create_payment_ticket', url: 'payment_tickets/new'}
    end
  end

end