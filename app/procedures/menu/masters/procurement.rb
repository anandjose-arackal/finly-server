class Menu::Masters::Procurement < Menu::API

  def self.accept?(user)
    user.user_panel_subscription.yes_bank_account_transfer
  end

  app :vp

  item :global_search, label: "Search (Alt+/)", icon: 'https://img.icons8.com/windows/20/ffffff/search.png',
       toggle: [GlobalSearchToggle, :enabled?]
  item :create, icon: 'https://img.icons8.com/windows/20/ffffff/plus-math.png' do
    action :redirect,
           :new_purchase_request,
           permissions: :purchase_request_initiator,
           features: :procurement,
           label: 'New Purchase Request',
           url: 'purchase_request'

    action :template,
           :new_purchase_order,
           permissions: :purchase_order_initiator,
           features: :procurement,
           policy: ::Docs::P2P::PurchaseOrders::Policy,
           model: ::PurchaseOrder,
           label: 'New PO',
           function: "po_create"

    action :template,
           :new_non_po_invoice,
           permissions: :non_po_invoice_initiator,
           features: :procurement,
           label: "New Non PO Invoice",
           policy: ::Docs::P2P::Invoices::Policy,
           model: ::Invoice,
           function: "non_po_invoice_create"

    action :redirect,
           :new_payment_ticket,
           policy: ::Docs::PaymentTickets::Policy,
           model: ::BankPaymentRequest,
           permissions: :bank_payment_request_initiator,
           label: 'New Payment Ticket',
           url: 'new_payment_ticket'

    action :redirect,
           :create,
           format: 'primary',
           permissions: :payment_agreement_initiator,
           features: :agreement_based_payment_system,
           label: 'New Agreement',
           icon: 'https://img.icons8.com/windows/17/708090/--checkmark-yes.png',
           url: 'agreements/new'

    action :redirect,
           :new_vendor,
           permissions: [:vendor_creator, :vendor_manager],
           toggle: {unless: [VendorToggle, :forms_enabled?]},
           policy: ::Masters::Vendors::Policy,
           model: ::YesBankVendor,
           label: 'New Vendor',
           url: 'vendor/add'

    action :redirect,
           :new_vendor_form,
           permissions: [:vendor_creator, :vendor_manager],
           toggle: {if: [VendorToggle, :forms_enabled?]},
           model: ::YesBankVendor,
           label: 'New Vendor',
           url: 'vendors/add'
  end

  item :dashboard, icon: 'https://img.icons8.com/windows/20/ffffff/speed.png'

  scope features: [:procurement, :purchase_requisition_system] do
    item :purchase_requests, label: 'Request', path: 'purchase_requests', icon: 'https://img.icons8.com/windows/20/ffffff/request-money.png',
         permissions: Docs::P2P::PurchaseRequests::Index.permissions
  end

  item :procure, features: :procurement, icon: 'https://img.icons8.com/windows/20/ffffff/add-shopping-cart.png' do
    item :purchase_orders, permissions: Docs::P2P::PurchaseOrders::Index.permissions
    item :pr_approved_items, label: "PR Approved Items", permissions: [:purchase_order_initiator, :admin]
  end

  item :receive, features: [:procurement, :grn_enabled], permissions: Docs::P2P::Inwards::Received::Index.permissions, icon: 'https://img.icons8.com/windows/20/ffffff/borrow-book.png' do
    item :receive_pending, path: 'receive'
    item :receive_history, path: 'receive/history'
  end

  item :payables, features: :procurement, icon: "https://img.icons8.com/windows/20/ffffff/sales-performance.png" do
    item :po_advances, label: 'PO Advances', permissions: Docs::P2P::PurchaseOrders::Advances::Index.permissions
    item :invoices, permissions: Docs::P2P::Invoices::Index.permissions
    item :utility_bills, permissions: Docs::UtilityBills::Subscriptions::Index.permissions
    item :upcoming_invoices, permissions: Docs::P2P::Invoices::Agreement::UpcomingInvoices::Index.permissions
    # item :unbilled_items, permissions: [] # todo
  end

  item :payments, icon: "https://img.icons8.com/windows/20/ffffff/online-money-transfer.png" do
    item :payment_tickets, permissions: Docs::PaymentTickets::Index.permissions
    item :payments, label: "Payment Items", permissions: Docs::PaymentTickets::Payments::Index.permissions
  end

  item :manage, icon: 'https://img.icons8.com/windows/20/ffffff/commercial-development-management.png' do
    item :analytics, permissions: [:admin], features: :analytics_system
    item :vendors, permissions: Masters::Vendors::Index.permissions
    item :items, permissions: Masters::Items::Index.permissions
    item :rate_contracts, permissions: Masters::RateContracts::Index.permissions, features: :procurement
    item :agreements, features: :agreement_based_payment_system,
         permissions: Docs::P2P::Agreements::Index.permissions
    item :credit_notes, permissions: Docs::P2P::CreditNotes::Index.permissions, features: :procurement
    item :utility_subscriptions, permissions: Docs::UtilityBills::Subscriptions::Index.permissions, features: :utility_bills_enabled
    item :users, permissions: [:admin]
    item :audit_trails, permissions: Docs::AuditTrail::Index.permissions
  end

  item :accounts, icon: 'https://img.icons8.com/windows/20/ffffff/wallet.png' do
    item :statements, permissions: [:admin]
    item :balances
  end

  item :download_manager, icon: "https://img.icons8.com/windows/20/ffffff/software-installer.png"
  item :settings, path: 'organization_account', permissions: [:admin], icon: "https://img.icons8.com/windows/20/ffffff/settings.png"

  footer_item :switch_version, icon: 'https://img.icons8.com/windows/20/ffffff/versions.png', options: {do_not_build_path: true}
  footer_item :notifications, icon: 'https://img.icons8.com/windows/20/ffffff/appointment-reminders.png', options: {do_not_build_path: true}
  footer_item :hide_menu, icon: 'https://img.icons8.com/windows/20/ffffff/double-left.png', options: {do_not_build_path: true}
  footer_item :account_settings, label: "My Account", icon: 'https://img.icons8.com/windows/20/ffffff/user.png'
  footer_item :support, label: "Help Center", icon: 'https://img.icons8.com/windows/20/ffffff/software-installer.png', options: {do_not_build_path: true} do
    item :new_releases, label: "What's New", icon: 'https://img.icons8.com/ios-glyphs/25/D298E4/commercial.png', options: {do_not_build_path: true}, toggle: [AnnouncementToggle, :product_stash]
  end

end