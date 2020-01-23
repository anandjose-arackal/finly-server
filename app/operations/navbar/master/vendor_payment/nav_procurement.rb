class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs,
      [
          :dashboard,
          {requests: [:pr_initiator, :pr_awaiting_approval, :pr_team, :pr_company]},
          {procure: [:divider, :po_section, :po_initiator, :po_awaiting_approval, :po_team, :po_company, :divider, :pr_approved_items]},
          {receive: [:receive_pending, :receive_history]},
          {payables: [:po_advances,:divider, :invoices_section,  :po_invoices, :non_po_invoices, :agreement_invoices, :upcoming_invoices,:divider, :utility_bills, :divider, :payment_tickets]},
          {manage: [:manage_vendors, :manage_item_master, :manage_rate_contracts, :manage_payment_agreements, :utility_bill_masters]},
          :download_manager,
          # :analytics,
          {create: [:create_purchase_order, :create_non_po_invoice, :create_payment_ticket, :create_purchase_request, :create_payment_agreement]}
      ]
  )

  register_structure(
      :cog_menu,
      [
          :attachments, :users,
          :load_company_balance, :statements,
          :organization_account,
          :exports
      ]
  )

  register_structure(
      :cog_modules,
      [
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

  def download_manager
    {name: 'Download Manager', id: 'download_manager', url: 'download_manager'}
  end

  def procure
    return nil unless user.company.procurement_enabled?
    {name: 'Procure', id: 'procure', url: 'purchase_orders'}
  end

  def po_section
    {type: 'section', name: 'Purchase Order'}
  end

  def po_initiator
    return nil unless user.is_purchase_order_initiator?
    {name: 'Your POs', id: 'procure', url: "purchase_orders/params={\"filter_user_id\":\"#{user.id}\",\"filter_user_name\":\"#{user.name}\"}"}
  end

  def po_awaiting_approval
    return nil unless user.is_purchase_order_reviewer?
    {name: 'POs Awaiting Approval', indent: true, id: 'procure', url: 'purchase_orders/params={"filter_status":"awaiting_approval"}'}
  end

  def po_team
    return nil unless user.is_purchase_order_reviewer?
    # {name: 'Team POs', id: 'procure', url: 'purchase_orders'}
    {name: 'Team POs', indent: true, id: 'procure', url: 'purchase_orders/params={"team_po":"true"}'}
  end

  def po_company
    return nil unless user.vp_admin_or_auditor? || user.is_purchase_order_auditor?
    {name: 'Company POs', indent: true, id: 'procure', url: 'purchase_orders'}
  end

  def receive
    return nil unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
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
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor? || user.is_purchase_order_auditor?
    {name: 'PO Advances', id: 'payables', url: 'new_payment_po_advances/params={}'}
  end

  def invoices_section
    {type: 'section', name: 'Invoices'}
  end

  def po_invoices
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor? || user.is_po_invoice_initiator? || user.is_po_invoice_reviewer? || user.is_po_invoice_auditor?
    {name: 'PO Invoices', indent: true, id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"po_invoice"}'}
  end

  def non_po_invoices
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor? || user.is_purchase_order_initiator? || user.is_purchase_order_reviewer? || user.is_non_po_invoice_initiator? || user.is_non_po_invoice_reviewer? || user.is_non_po_invoice_auditor?
    {name: 'Non PO Invoices', indent: true, id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"non_po_invoice"}'}
  end

  def agreement_invoices
    return nil unless user.company.agreement_based_payment_system_enabled? && (user.is_payment_agreement_initiator? || user.vendor_payments_admin? || user.is_payment_agreement_auditor?)
    {name: 'Agreement Invoices', indent: true, id: 'payables', url: 'new_payment_invoices/params={"filter_invoice_type":"agreement_invoice"}'}
  end

  def upcoming_invoices
    return nil unless user.company.agreement_based_payment_system_enabled? && (user.is_payment_agreement_initiator? || user.vendor_payments_admin? || user.is_payment_agreement_auditor? || user.is_non_po_invoice_initiator?)
    {name: 'Upcoming Invoices', id: 'payables', url: 'upcoming_invoices'}
  end

  def utility_bills
    return nil unless user.company.utility_bills_enabled? &&
        (
        user.vendor_payment_admin? ||
            user.is_utility_bill_master_initiator? ||
            user.is_utility_bill_master_reviewer? ||
            user.is_utility_bill_initiator? ||
            user.is_utility_bill_reviewer? ||
            user.is_bank_payment_request_initiator? ||
            user.is_bank_payment_request_reviewer? ||
            user.is_bank_payment_request_creditor? ||
            user.is_bank_payment_request_auditor?
        )
    {name: 'Utility Bills', id: 'payables', url: 'utility_bills'}
  end

  def payment_tickets
    return nil unless user.is_bank_payment_request_initiator? || user.is_bank_payment_request_reviewer? || user.is_bank_payment_request_creditor? || user.vp_admin_or_auditor? || user.is_bank_payment_request_auditor?
    {name: 'Payment Tickets', id: 'payables', url: 'orders'}
  end

  def manage
    {name: 'Manage', id: 'manage', url: 'vendor'}
  end

  def manage_vendors
    # return nil unless user.is_vendor_manager? || user.is_vendor_initiator? || user.is_vendor_reviewer? || user.vp_admin_or_auditor?
    {name: 'Vendors', id: 'manage', url: 'vendor'}
  end

  def manage_item_master
    return nil unless user.is_item_master_manager? || user.vp_admin_or_auditor?
    {name: 'Item Master', id: 'manage', url: 'catalogue/params={"tabName": "item_master"}'}
  end

  def manage_rate_contracts
    return nil unless user.company.procurement_enabled?
    # return nil unless user.is_item_master_manager? || user.vp_admin_or_auditor?
    {name: 'Rate Contracts', id: 'manage', url: 'catalogue/params={"tabName": "rate_contract"}'}
  end

  def utility_bill_masters
    return nil unless user.company.utility_bills_enabled? &&
        (
        user.vendor_payment_admin? ||
            user.is_utility_bill_master_initiator? ||
            user.is_utility_bill_master_reviewer? ||
            user.is_utility_bill_initiator? ||
            user.is_utility_bill_reviewer? ||
            user.is_bank_payment_request_initiator? ||
            user.is_bank_payment_request_reviewer? ||
            user.is_bank_payment_request_creditor? ||
            user.is_bank_payment_request_auditor?
        )
    {name: 'Utility Bill Masters', id: 'manage', url: 'utility_bill_masters/params={"tabName": "agreements"}'}
  end

  def track_bbps_complaints
    return nil unless user.company.utility_bills_enabled?
    {name: 'BBPS Complaints', id: 'manage', url: 'track_bill_complaint/params={"tabName": "agreements"}'}
  end

  def manage_payment_agreements
    return nil unless (user.is_payment_agreement_initiator? || user.vp_admin_or_auditor? || user.is_payment_agreement_auditor? || user.is_payment_agreement_reviewer?) && user.company.agreement_based_payment_system_enabled?
    {name: 'Agreements', id: 'manage', url: 'agreements/params={"tabName": "agreements"}'}
  end

  def credit_notes
    # return nil unless (
    #       user.credit_note_initiator? ||
    #       user.vp_admin_or_auditor? || user.is_payment_agreement_auditor? || user.is_payment_agreement_reviewer?) && user.company.agreement_based_payment_system_enabled?
    {name: 'Credit Notes', id: 'manage', url: 'credit_notes/params={"tabName": "agreements"}'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    return nil unless user.is_purchase_order_initiator? || user.vendor_payments_admin?
    {name: 'New Purchase Order', id: 'create', url: 'purchase_orders/params={"action":"new_purchase_order"}'}
  end

  # def create_po_invoice
  #   {name: 'New PO Invoice', id: 'create_po_invoice', url: 'purchase_orders/invoices/new'}
  # end

  def create_non_po_invoice
    return nil unless user.vendor_payments_admin? || user.is_non_po_invoice_initiator?
    {name: 'New Non PO Invoice', id: 'create', url: 'new_payment_invoices/params={"action":"new_invoice","filter_invoice_type":"non_po_invoice"}'}
  end

  def create_payment_ticket
    return nil unless user.is_bank_payment_request_initiator? || user.vendor_payments_admin?
    {name: 'New Payment Ticket', id: 'create', url: 'new_payment_ticket/params={}'}
  end

  def create_purchase_request
    return nil unless user.is_purchase_request_initiator? || user.vendor_payments_admin?
    {name: 'New Purchase Request', id: 'create', url: 'purchase_request/params={}'}
  end

  def create_payment_agreement
    return nil unless user.company.agreement_based_payment_system_enabled? && (user.is_payment_agreement_initiator? || user.vendor_payments_admin?)
    {name: 'New Agreements', id: 'create', url: 'agreements/new'}
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
    return nil unless user.is_purchase_request_reviewer? || user.is_purchase_order_initiator? || user.vendor_payments_admin?
    {name: 'PRs Awaiting Approval', id: 'requests', url: 'purchase_requests/params={"filter_awaiting_approval":"1"}'}
  end

  def pr_company
    return nil unless user.vp_admin_or_auditor? || user.is_purchase_request_auditor?
    {name: 'Company PRs', id: 'requests', url: 'purchase_requests'}
  end

  def pr_approved_items
    return nil unless user.company.purchase_requisition_enabled? && (user.is_purchase_order_initiator? || user.is_inventory_manager? || user.vp_admin_or_auditor? || user.is_purchase_request_auditor?)
    {name: 'Approved Items', id: 'procure', url: 'po_approval_items/params={}'}
  end

  def pr_initiator
    return nil unless user.is_purchase_request_initiator?
    {name: 'Your PRs', id: 'requests', url: "purchase_requests/params={\"search_by_email\":\"#{user.email}\"}"}
  end

  def analytics
    {name: 'Analytics', id: 'analytics', url: "analytics/params={}"}
  end

end