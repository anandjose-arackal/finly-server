class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs,
      [
          :dashboard,
          {procure: [:po_initiator, :po_awaiting_approval, :po_team, :po_company]},
          {receive: [:receive_pending, :receive_history]},
          {payables: [:po_advances, :po_invoices, :non_po_invoices, :payment_tickets]},
          {manage: [:manage_vendors, :manage_item_master, :manage_rate_contracts]},
          {create: [:create_purchase_order, :create_non_po_invoice, :create_payment_ticket]}
      ]
  )
  register_structure(
      :cog,
      [
          :attachments, :users,
          :load_company_balance, :statements,
          :organization_account,
          :finly_expense_management, :finly_disburse, :finly_collect
      ]
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
    return nil unless user.is_purchase_order_initiator?
    {name: 'Your POs', id: 'procurements', url: 'procurements'}
  end

  def po_awaiting_approval
    return nil unless user.is_purchase_request_reviewer? || user.vendor_payments_admin?
    {name: 'POs Awaiting Approval', id: 'procurements', url: 'procurements'}
  end

  def po_team
    return nil unless user.is_purchase_request_reviewer?
    {name: 'Team POs', id: 'procurements', url: 'procurements'}
  end

  def po_company
    return nil unless user.vendor_payments_admin?
    {name: 'Company POs', id: 'procurements', url: 'procurements'}
  end

  def receive
    {name: 'Receive', id: 'receive', url: 'receive'}
  end

  def receive_pending
    return nil unless user.is_goods_receiver?
    {name: 'Pending', id: 'receive_pending', url: '#receive/params={"active_tab":"pending-tab"}'}
  end

  def receive_history
    return nil unless user.is_goods_receiver?
    {name: 'Received', id: 'receive_received', url: '#receive/params={"active_tab":"receive-tab"}'}
  end

  def payables
    {name: 'Payables', id: 'orders', url: 'orders'}
  end

  # def unbilled_items
  #   {name: 'Unbilled Items', id: 'payables_unbilled_items', url: 'payables/unbilled_items'}
  # end

  def po_advances
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'PO Advances', id: 'new_payment_po_advances', url: 'new_payment_po_advances'}
  end

  def po_invoices
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'PO Invoices', id: 'new_payment_invoices', url: 'new_payment_invoices/params={"filter_invoice_type":"po_invoice"}'}
  end

  def non_po_invoices
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'Non PO Invoices', id: 'new_payment_invoices', url: 'new_payment_invoices/params={"filter_invoice_type":"non_po_invoice"}'}
  end

  def payment_tickets
    return nil unless user.is_bank_payment_request_initiator? || user.is_bank_payment_request_reviewer? || user.is_bank_payment_request_creditor?
    {name: 'Payment Tickets', id: 'orders', url: 'orders'}
  end

  def manage
    {name: 'Manage', id: 'beneficiaries', url: 'beneficiaries'}
  end

  def manage_vendors
    return nil unless user.is_vendor_manger? || user.is_vendor_initiator? || user.is_vendor_reviewer? || user.vendor_payments_admin?
    {name: 'Vendors', id: 'beneficiaries', url: 'beneficiaries'}
  end

  def manage_item_master
    return nil unless user.is_item_master_manager? || user.vendor_payments_admin?
    {name: 'Item Master', id: 'item_master', url: 'catalogue/params={"tabName": "item_master"}'}
  end

  def manage_rate_contracts
    return nil unless user.is_item_master_manager? || user.vendor_payments_admin?
    {name: 'Rate Contracts', id: 'rate_contracts', url: 'catalogue/params={"tabName": "rate_contract"}'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    return nil unless user.is_purchase_order_initiator? || user.vendor_payments_admin?
    {name: 'New Purchase Order', id: 'create_purchase_order', url: 'procurements/params={"action":"new_procurement"}'}
  end

  # def create_po_invoice
  #   {name: 'New PO Invoice', id: 'create_po_invoice', url: 'purchase_orders/invoices/new'}
  # end

  def create_non_po_invoice
    return nil unless user.is_invoice_initiator? || user.vendor_payments_admin?
    {name: 'New Non PO Invoice', id: 'create_non_po_invoice', url: 'new_payment_invoices/params={"action":"new_invoice"}'}
  end

  def create_payment_ticket
    return nil unless user.is_bank_payment_request_initiator? || user.vendor_payments_admin?
    {name: 'New Payment Ticket', id: 'new_payment_ticket', url: 'new_payment_ticket'}
  end

  def attachments
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'Attachments', id: 'attachments', url: 'attachments'}
  end

end