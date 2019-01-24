class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_app :vp
  register_structure(
      [
          :dashboard,
          :invoices,
          :payment_tickets,
          :manage_vendors,
          :manage_catalogue,
          :create,
          :create_payment_ticket
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

  def invoices
    {name: 'Invoices', id: 'payables_invoices', url: 'payables/invoices'}
  end

  def payment_tickets
    {name: 'Payment Tickets', id: 'payables_payment_tickets', url: 'payables/payment_tickets'}
  end

  def manage_vendors
    {name: 'Vendors', id: 'manage_vendors', url: 'manage/vendors'}
  end

  def manage_catalogue
    {name: 'Catalogue', id: 'manage_catalogue', url: 'manage/catalogue'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_payment_ticket
    {name: 'New Payment Ticket', id: 'create_payment_ticket', url: 'payment_tickets/new'}
  end

end