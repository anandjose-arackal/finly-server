class Navbar::Master::VendorPayment::NavPayment < Navbar::Master::Base

  register_app :vp
  register_structure(
      :tabs, [
          :dashboard,
          :payment_tickets,
          :vendors,
          :item_master,
          {create: [:create_payment_ticket]},
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
    {name: 'Payment Tickets', id: 'orders', url: 'orders'}
  end

  def vendors
    {name: 'Vendors', id: 'beneficiaries', url: 'beneficiaries'}
  end

  def item_master
    {name: 'Item Master', id: 'inventory', url: 'inventory'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_payment_ticket
    if is_bank_payment_request_initiator? || user.vendor_payments_admin?
      {name: 'New Payment Ticket', id: 'create_payment_ticket', url: 'payment_tickets/new'}
    end
  end

end