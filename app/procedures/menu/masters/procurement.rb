class Menu::Masters::Procurement < Menu::API

  def self.accept?(user)
    true
  end

  app :vp

  item :create, icon: 'https://img.icons8.com/windows/20/ffffff/plus-math.png' do
    action :redirect,
           :new_purchase_request,
           permissions: :purchase_request_initiator,
           label: 'New Purchase Request',
           url: 'purchase_requests/new'

    action :template,
           :new_purchase_order,
           permissions: :purchase_order_initiator,
           policy: ::Docs::P2P::PurchaseOrders::Policy,
           model: ::PurchaseOrder,
           label: 'Create PO',
           function: "po_create"

    action :template,
           :new_non_po_invoice,
           permissions: :non_po_invoice_initiator,
           label: "Create Non PO Invoice",
           policy: ::Docs::P2P::Invoices::Policy,
           model: ::Invoice,
           function: "non_po_invoice_create"

    action :redirect,
           :new_payment_ticket,
           policy: ::Docs::PaymentTickets::Policy,
           model: ::BankPaymentRequest,
           permissions: :bank_payment_request_initiator,
           label: 'Create Payment Ticket',
           url: 'payment_tickets/new'

    # Todo agreement
    # action :new_agreement, path: 'agreements/new', permissions: [:agreement_invoice_initiator]

    action :redirect,
           :new_vendor,
           permissions: [:vendor_creator, :vendor_manager],
           policy: ::Masters::Vendors::Policy,
           model: ::YesBankVendor,
           label: 'Add Vendor',
           url: 'vendor/add'
  end

  item :dashboard, icon: 'https://img.icons8.com/windows/20/ffffff/speed.png'

  scope features: :purchase_requisition_system do
    item :request, path: 'purchase_requests', icon: 'https://img.icons8.com/windows/20/ffffff/request-money.png',
         permissions: [:purchase_request_initiator, :purchase_request_reviewer, :admin]
  end

  item :procure, icon: 'https://img.icons8.com/windows/20/ffffff/add-shopping-cart.png' do
    item :purchase_orders, permissions: [:purchase_order_initiator, :purchase_order_reviewer, :purchase_order_auditor, :admin]
    item :pr_approved_items, label: "PR Approved Items", permissions: [:purchase_order_initiator, :admin]
  end

  item :receive, permissions: :goods_receiver, icon: 'https://img.icons8.com/windows/20/ffffff/borrow-book.png' do
    item :receive_pending, path: 'receive'
    item :receive_history, path: 'receive/history'
  end

  item :payables, icon: "https://img.icons8.com/windows/20/ffffff/sales-performance.png" do
    item :po_advances, label: "PO Advances", permissions: [:bank_payment_request_initiator, :auditor, :admin]
    item :invoices, permissions: [
        :bank_payment_request_initiator, :invoice_initiator, :invoice_reviewer,
        :invoice_auditor, :po_invoice_initiator, :po_invoice_reviewer, :po_invoice_auditor,
        :non_po_invoice_initiator, :non_po_invoice_reviewer, :non_po_invoice_auditor, :admin
    ]
    item :utility_bills, permissions: [:utility_bill_initiator, :utility_bill_reviewer, :bank_payment_request_initiator, :admin]
    item :upcoming_invoices, permissions: [:agreement_invoice_initiator, :agreement_invoice_auditor, :admin]
    # item :unbilled_items, permissions: [] # todo
  end

  item :payments, icon: "https://img.icons8.com/windows/20/ffffff/online-money-transfer.png" do
    item :payment_tickets, permissions: [:bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :auditor, :admin]
    item :payments, permissions: [:bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :auditor, :admin]
  end

  item :manage, icon: 'https://img.icons8.com/windows/20/ffffff/commercial-development-management.png' do
    item :analytics, permissions: [:admin]
    item :vendors, permissions: [:vendor_creator, :vendor_reviewer, :vendor_manager, :vendor_auditor, :auditor, :admin]
    item :items, permissions: [:item_master_manager, :inventory_manager, :auditor, :admin]
    item :rate_contracts, permissions: [:inventory_manager, :auditor, :admin]
    # user.is_agreement_invoice_initiator? || user.is_agreement_invoice_reviewer? || user.is_agreement_invoice_auditor? ||
    # user.is_payment_agreement_initiator? || user.vp_admin_or_auditor? || user.is_payment_agreement_auditor? || user.is_payment_agreement_reviewer?
    item :agreements, features: :agreement_based_payment_system,
         permissions: [
             :agreement_invoice_initiator, :agreement_invoice_reviewer, :agreement_invoice_auditor,
             :payment_agreement_initiator, :payment_agreement_reviewer, :payment_agreement_auditor, :auditor, :admin
         ]
    item :credit_notes, permissions: [:credit_note_initiator, :credit_note_reviewer, :credit_note_auditor, :admin]
    item :utility_subscriptions, permissions: [:utility_bill_master_initiator, :utility_bill_master_reviewer, :admin]
    item :users, permissions: [:admin]
  end

  item :download_manager, icon: "https://img.icons8.com/windows/20/ffffff/software-installer.png"
  item :balances, icon: 'https://img.icons8.com/windows/20/ffffff/wallet.png'
  item :settings, path: 'organization_account', permissions: [:admin], icon: "https://img.icons8.com/windows/20/ffffff/settings.png"

end