class Navbar::Master::VendorPayment::NavPayment < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs, [
      :dashboard,
      :item_master,
      :vendors,
      :payment_tickets,
      {create: [:create_payment_ticket]}
  ]
  )

  register_structure(
      :cog, [
      :users,
      :load_company_balance, :statements,
      :organization_account,
      :finly_expense_management, :finly_disburse, :finly_collect
  ]
  )

  def self.accept?
    return false if RequestStoreUtil.current_company&.feature_subscription&.procurement
    return false unless RequestStoreUtil.current_company.feature_subscription.yes_bank_account
    return false unless RequestStoreUtil.current_user.user_panel_subscription.yes_bank_account_transfer
    true
  end

  def dashboard
    {name: 'Dashboard', id: 'dashboard', url: 'dashboard'}
  end

  def payment_tickets
    {name: 'Payment Tickets', id: 'payment_tickets', url: 'orders'}
  end

  def vendors
    return nil unless user.is_vendor_creator? || user.vp_admin_or_auditor?
    {name: 'Vendors', id: 'vendors', url: 'beneficiaries/params={}'}
  end

  def item_master
    return nil unless user.is_item_master_manager? || user.vp_admin_or_auditor?
    {name: 'Item Master', id: 'item_master', url: 'inventory/params={}'}
  end

  def create
    return nil unless user.initiator_for_any_document? || user.vp_admin_or_auditor?
    {name: 'Create', id: 'create', url: 'create/params={}'}
  end

  def create_payment_ticket
    return nil unless user.is_bank_payment_request_initiator? || user.vp_admin_or_auditor?
    {name: 'New Payment Ticket', id: 'new_payment_ticket', url: 'new_payment_ticket/params={}'}
  end

end