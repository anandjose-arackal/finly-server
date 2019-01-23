class Navbar::Master::VendorPayment::NavProcurement < Navbar::Master::Base

  register_type :procurement
  register_structure(
      [
          :dashboard,
          {procure: [:po, :po_vendors, :po_catalogue]},
          :shipments,
          {payables: [:unbilled_items, :po_advances, :invoices, :payment_tickets]},
          {manage: [:manage_vendors, :manage_catalogue, :manage_rate_contracts]},
          {create: [:create_purchase_order, :create_non_po_invoice, :create_payment_ticket]}
      ]
  )

  def self.accept?
    true or RequestStoreUtil.current_company&.feature_subscription&.procurement
  end

  def dashboard
    {name: 'Dashboard', id: 'dashboard', url: 'dashboard'}
  end

  def procure
    {name: 'Procure', id: 'procure', url: 'procure'}
  end

  def po
    {name: 'Purchase Orders', id: 'purchase_orders', url: 'purchase_orders'}
  end

  def po_vendors
    {name: 'Vendors', id: 'po_vendors', url: 'purchase_orders/vendors'}
  end

  def po_catalogue
    {name: 'Catalogue', id: 'po_catalogue', url: 'purchase_orders/catalogue'}
  end

  def shipments
    {name: 'Shipments', id: 'po_shipments', url: 'purchase_orders/shipments'}
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
    {name: 'Vendors', id: 'manage_vendors', url: 'manage/vendors'}
  end

  def manage_catalogue
    {name: 'Catalogue', id: 'manage_catalogue', url: 'manage/catalogue'}
  end

  def manage_rate_contracts
    {name: 'Rate Contracts', id: 'manage_rate_contracts', url: 'manage/rate_contracts'}
  end

  def create
    {name: 'Create', id: 'create', url: 'create'}
  end

  def create_purchase_order
    {name: 'New Purchase Order', id: 'create_purchase_order', url: 'purchase_orders/new'}
  end

  def create_non_po_invoice
    {name: 'New Non PO Invoice', id: 'create_non_po_invoice', url: 'non_po_invoices/new'}
  end

  def create_payment_ticket
    {name: 'New Payment Ticket', id: 'create_payment_ticket', url: 'payment_tickets/new'}
  end

end