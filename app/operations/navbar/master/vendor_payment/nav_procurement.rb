class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs,
      [
          :dashboard,
          {procure: [:po_initiator, :po_awaiting_approval, :po_team, :po_company]},
          {receive: [:receive_pending, :receive_history]},
          {payables: [:po_advances, :invoices, :payment_tickets]},
          {manage: [:manage_vendors, :manage_item_master, :manage_rate_contracts]},
          {create: [:create_purchase_order, :create_non_po_invoice, :create_payment_ticket]}
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
    {name: 'Procure', id: 'procurements', url: 'procurements'}
  end

  def po_initiator
    {name: 'Your POs', id: 'procurements', url: 'procurements'}
  end

  def po_awaiting_approval
    {name: 'POs Awaiting Approval', id: 'procurements', url: 'procurements'}
  end

  def po_team
    {name: 'Team POs', id: 'procurements', url: 'procurements'}
  end

  def po_company
    {name: 'Company POs', id: 'procurements', url: 'procurements'}
  end

  def receive
    {name: 'Receive', id: 'receive', url: 'receive'}
  end

  def receive_pending
    {name: 'Pending', id: 'receive', url: 'receive'}
  end

  def receive_history
    {name: 'Received', id: 'receive', url: 'receive'}
  end

  def payables
    {name: 'Payables', id: 'orders', url: 'orders'}
  end

  # def unbilled_items
  #   {name: 'Unbilled Items', id: 'payables_unbilled_items', url: 'payables/unbilled_items'}
  # end

  def po_advances
    {name: 'PO Advances', id: 'new_payment_po_advances', url: 'new_payment_po_advances'}
  end

  def invoices
    {name: 'Invoices', id: 'new_payment_invoices', url: 'new_payment_invoices'}
  end

  def payment_tickets
    {name: 'Payment Tickets', id: 'orders', url: 'orders'}
  end

  def manage
    {name: 'Manage', id: 'beneficiaries', url: 'beneficiaries'}
  end

  def manage_vendors
    {name: 'Vendors', id: 'beneficiaries', url: 'beneficiaries'}
  end

  def manage_item_master
    {name: 'Item Master', id: 'inventory', url: 'inventory'}
  end

  def manage_rate_contracts
    {name: 'Rate Contracts', id: 'inventory', url: 'inventory'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    {name: 'New Purchase Order', id: 'create_purchase_order', url: 'purchase_orders/new'}
  end

  # def create_po_invoice
  #   {name: 'New PO Invoice', id: 'create_po_invoice', url: 'purchase_orders/invoices/new'}
  # end

  def create_non_po_invoice
    {name: 'New Non PO Invoice', id: 'create_non_po_invoice', url: 'non_po_invoices/new'}
  end

  def create_payment_ticket
    {name: 'New Payment Ticket', id: 'new_payment_ticket', url: 'new_payment_ticket'}
  end

  def attachments
    {name: 'Attachments', id: 'attachments', url: 'attachments'}
  end

end