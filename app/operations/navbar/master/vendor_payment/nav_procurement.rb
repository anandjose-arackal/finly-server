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
    return nil unless user.company.procurement_enabled?
    {name: 'Procure', id: 'procure', url: 'procurements'}
  end

  def po_initiator
    return nil unless user.is_purchase_order_initiator? || user.vp_admin_or_auditor?
    {name: 'Your POs', id: 'procure', url: 'procurements'}
  end

  def po_awaiting_approval
    return nil unless user.is_purchase_order_reviewer? || user.vp_admin_or_auditor?
    {name: 'POs Awaiting Approval', id: 'procure', url: 'procurements'}
  end

  def po_team
    return nil unless user.is_purchase_order_reviewer? || user.vp_admin_or_auditor?
    {name: 'Team POs', id: 'procure', url: 'procurements'}
  end

  def po_company
    return nil unless user.vp_admin_or_auditor?
    {name: 'Company POs', id: 'procure', url: 'procurements'}
  end

  def receive
    {name: 'Receive', id: 'receive', url: 'receive'}
  end

  def receive_pending
    return nil unless user.is_goods_receiver?
    {name: 'Pending', id: 'receive', url: '#receive/params={"active_tab":"pending-tab"}'}
  end

  def receive_history
    return nil unless user.is_goods_receiver?
    {name: 'Received', id: 'receive', url: '#receive/params={"active_tab":"receive-tab"}'}
  end

  def payables
    {name: 'Payables', id: 'payables', url: 'orders'}
  end

  # def unbilled_items
  #   {name: 'Unbilled Items', id: 'payables_unbilled_items', url: 'payables/unbilled_items'}
  # end

  def po_advances
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'PO Advances', id: 'payables', url: 'new_payment_po_advances/params={}'}
  end

  def po_invoices
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'PO Invoices', id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"po_invoice"}'}
  end

  def non_po_invoices
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'Non PO Invoices', id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"non_po_invoice"}'}
  end

  def payment_tickets
    return nil unless user.is_bank_payment_request_initiator? || user.is_bank_payment_request_reviewer? || user.is_bank_payment_request_creditor?
    {name: 'Payment Tickets', id: 'payables', url: 'orders'}
  end

  def manage
    {name: 'Manage', id: 'manage', url: 'beneficiaries/params={}'}
  end

  def manage_vendors
    return nil unless user.is_vendor_manger? || user.is_vendor_initiator? || user.is_vendor_reviewer? || user.vendor_payments_admin?
    {name: 'Vendors', id: 'manage', url: 'beneficiaries/params={}'}
  end

  def manage_item_master
    return nil unless user.is_item_master_manager? || user.vendor_payments_admin?
    {name: 'Item Master', id: 'manage', url: 'catalogue/params={"tabName": "item_master"}'}
  end

  def manage_rate_contracts
    return nil unless user.is_item_master_manager? || user.vendor_payments_admin?
    {name: 'Rate Contracts', id: 'manage', url: 'catalogue/params={"tabName": "rate_contract"}'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    return nil unless user.is_purchase_order_initiator? || user.vendor_payments_admin?
    {name: 'New Purchase Order', id: 'create', url: 'procurements/params={"action":"new_procurement"}'}
  end

  # def create_po_invoice
  #   {name: 'New PO Invoice', id: 'create_po_invoice', url: 'purchase_orders/invoices/new'}
  # end

  def create_non_po_invoice
    return nil unless user.is_invoice_initiator? || user.vendor_payments_admin?
    {name: 'New Non PO Invoice', id: 'create', url: 'new_payment_invoices/params={"action":"new_invoice"}'}
  end

  def create_payment_ticket
    return nil unless user.is_bank_payment_request_initiator? || user.vendor_payments_admin?
    {name: 'New Payment Ticket', id: 'create', url: 'new_payment_ticket/params={}'}
  end

  def attachments
    return nil unless user.is_bank_payment_request_initiator?
    {name: 'Attachments', id: 'attachments', url: 'attachments/params={}'}
  end

end