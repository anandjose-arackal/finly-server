class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs,
      [
          :dashboard,
          {requests: [:pr_initiator, :pr_awaiting_approval, :pr_team, :pr_company]},
          {procure: [:po_initiator, :po_awaiting_approval, :po_team, :po_company, :pr_approved_items]},
          {receive: [:receive_pending, :receive_history]},
          {payables: [:po_advances, :po_invoices, :non_po_invoices, :payment_tickets]},
          {manage: [:manage_vendors, :manage_item_master, :manage_rate_contracts]},
          {create: [:create_purchase_order, :create_non_po_invoice, :create_payment_ticket, :create_purchase_request]}
      ]
  )
  register_structure(
      :cog,
      [
          :attachments, :users,
          :load_company_balance, :statements,
          :organization_account,
          :finly_expense_management, :finly_disburse, :finly_collect, :finly_insights
      ]
  )

  def self.accept?
    return false unless RequestStoreUtil.current_user.user_panel_subscription.yes_bank_account_transfer
    return false unless RequestStoreUtil.current_company&.feature_subscription&.procurement
    true
  end

  def dashboard
    {name: 'Dashboard', id: 'dashboard', url: 'dashboard/params={}'}
  end

  def procure
    return nil unless user.company.procurement_enabled?
    {name: 'Procure', id: 'procure', url: 'procurements'}
  end

  def po_initiator
    return nil unless user.is_purchase_order_initiator?
    {name: 'Your POs', id: 'procure', url: "procurements/params={\"search_type\":\"user_details\",\"search_query\":\"#{user.email}\"}"}
  end

  def po_awaiting_approval
    return nil unless user.is_purchase_order_reviewer?
    {name: 'POs Awaiting Approval', id: 'procure', url: 'procurements/params={"filter_procurement_type":"purchase_order", "filter_awaiting_approval":"1"}'}
  end

  def po_team
    return nil unless user.is_purchase_order_reviewer?
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
    {name: 'Pending', id: 'receive', url: 'receive/params={"active_tab":"pending-tab"}'}
  end

  def receive_history
    return nil unless user.is_goods_receiver?
    {name: 'Received', id: 'receive', url: 'receive/params={"active_tab":"receive-tab"}'}
  end

  def payables
    {name: 'Payables', id: 'payables', url: 'orders'}
  end

  # def unbilled_items
  #   {name: 'Unbilled Items', id: 'payables_unbilled_items', url: 'payables/unbilled_items'}
  # end

  def po_advances
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor?
    {name: 'PO Advances', id: 'payables', url: 'new_payment_po_advances/params={}'}
  end

  def po_invoices
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor?
    {name: 'PO Invoices', id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"po_invoice"}'}
  end

  def non_po_invoices
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor? || user.is_purchase_order_initiator? || user.is_purchase_order_reviewer?
    {name: 'Non PO Invoices', id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"non_po_invoice"}'}
  end

  def payment_tickets
    return nil unless user.is_bank_payment_request_initiator? || user.is_bank_payment_request_reviewer? || user.is_bank_payment_request_creditor? || user.vp_admin_or_auditor?
    {name: 'Payment Tickets', id: 'payables', url: 'orders'}
  end

  def manage
    {name: 'Manage', id: 'manage', url: 'beneficiaries'}
  end

  def manage_vendors
    # return nil unless user.is_vendor_manager? || user.is_vendor_initiator? || user.is_vendor_reviewer? || user.vp_admin_or_auditor?
    {name: 'Vendors', id: 'manage', url: 'vendor'}
  end

  def manage_item_master
    # return nil unless user.is_item_master_manager? || user.vp_admin_or_auditor?
    {name: 'Item Master', id: 'manage', url: 'catalogue/params={"tabName": "item_master"}'}
  end

  def manage_rate_contracts
    return nil unless user.is_item_master_manager? || user.vp_admin_or_auditor?
    {name: 'Rate Contracts', id: 'manage', url: 'catalogue/params={"tabName": "rate_contract"}'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    return nil unless user.is_purchase_order_initiator? || user.vp_admin_or_auditor?
    {name: 'New Purchase Order', id: 'create', url: 'procurements/params={"action":"new_procurement"}'}
  end

  # def create_po_invoice
  #   {name: 'New PO Invoice', id: 'create_po_invoice', url: 'purchase_orders/invoices/new'}
  # end

  def create_non_po_invoice
    return nil unless user.is_invoice_initiator? || user.vp_admin_or_auditor?
    {name: 'New Non PO Invoice', id: 'create', url: 'new_payment_invoices/params={"action":"new_invoice","filter_invoice_type":"non_po_invoice"}'}
  end

  def create_payment_ticket
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor?
    {name: 'New Payment Ticket', id: 'create', url: 'new_payment_ticket/params={}'}
  end

  def create_purchase_request
    return nil unless user.is_purchase_request_initiator? || user.vp_admin_or_auditor?
    {name: 'New Purchase Request', id: 'create', url: 'purchase_request/params={}'}
  end

  def attachments
    # return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor?
    {name: 'Attachments', id: 'attachments', url: '#attachments/params={}'}
  end

  def requests
    return nil unless user.company.purchase_requisition_enabled?
    {name: 'Requests', id: 'requests', url: 'requests'}
  end

  def pr_team
    return nil unless user.is_purchase_request_reviewer?
    {name: 'Team PRs', id: 'requests', url: 'purchase_requests'}
  end

  def pr_awaiting_approval
    return nil unless user.is_purchase_request_reviewer? || user.is_purchase_order_initiator? || user.vp_admin_or_auditor?
    { name: 'PRs Awaiting Approval', id: 'requests', url: 'purchase_requests/params={"filter_awaiting_approval":"1"}' }
  end

  def pr_company
    return nil unless user.vp_admin_or_auditor?
    { name: 'Company PRs', id: 'requests', url: 'purchase_requests' }
  end

  def pr_approved_items
    return nil unless user.company.purchase_requisition_enabled? && (user.is_inventory_manager? || user.vp_admin_or_auditor?)
    { name: 'Approved Items', id: 'procure', url: 'po_approval_items/params={}'}
  end

  def pr_initiator
    return nil unless user.is_purchase_request_initiator?
    { name: 'Your PRs', id: 'requests', url: "purchase_requests/params={\"search_by_email\":\"#{user.email}\"}"}
  end

end