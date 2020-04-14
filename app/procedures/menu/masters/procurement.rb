class Menu::Masters::Procurement < Menu::API

  def self.accept?(user)
    true
  end

  app :vp

  item :dashboard, icon: 'https://img.icons8.com/windows/22/ffffff/speed.png'

  scope features: :purchase_requisition_system do
    item :request, path: 'purchase_requests', icon: 'https://img.icons8.com/windows/22/ffffff/request-money.png',
         permissions: [:purchase_request_initiator, :purchase_request_reviewer], create: true
  end

  item :procure, icon: 'https://img.icons8.com/windows/22/ffffff/add-shopping-cart.png' do
    item :purchase_orders, permissions: [:purchase_order_initiator, :purchase_order_reviewer, :purchase_order_auditor], create: true
    item :pr_approved_items, label: "PR Approved Items", permissions: [:purchase_order_initiator]
  end

  item :receive, permissions: :goods_receiver, icon: 'https://img.icons8.com/windows/22/ffffff/borrow-book.png' do
    item :receive_pending, path: 'receive'
    item :receive_history, path: 'receive/history'
  end

  item :payables, icon: "https://img.icons8.com/windows/22/ffffff/sales-performance.png" do
    item :po_advances, label: "PO Advances", permissions: [:bank_payment_request_initiator, :auditor]
    item :invoices, permissions: [:bank_payment_request_initiator], create: true
    item :utility_bills
    item :pending do
      item :upcoming_invoices, permissions: [:agreement_invoice_initiator, :agreement_invoice_auditor]
      # item :unbilled_items, permissions: [] # todo
    end
  end

  item :payments, icon: "https://img.icons8.com/windows/22/ffffff/sales-performance.png" do
    item :payment_tickets, permissions: [:bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :auditor]
    item :payments, permissions: [:bank_payment_request_initiator, :bank_payment_request_reviewer, :bank_payment_request_creditor, :auditor]
  end

  item :manage, icon: "https://img.icons8.com/windows/22/ffffff/commercial-development-management.png" do
    item :analytics, permissions: [:admin]
    item :vendors, create: true, permissions: [:vendor_creator, :vendor_reviewer, :vendor_manager, :vendor_auditor, :auditor]
    item :items, create: true, permissions: [:item_master_manager, :inventory_manager, :auditor]
    item :rate_contracts, create: true, permissions: [:inventory_manager, :auditor]
    # user.is_agreement_invoice_initiator? || user.is_agreement_invoice_reviewer? || user.is_agreement_invoice_auditor? ||
    # user.is_payment_agreement_initiator? || user.vp_admin_or_auditor? || user.is_payment_agreement_auditor? || user.is_payment_agreement_reviewer?
    item :agreements, create: true, features: :agreement_based_payment_system,
         permissions: [
             :agreement_invoice_initiator, :agreement_invoice_reviewer, :agreement_invoice_auditor,
             :payment_agreement_initiator, :payment_agreement_reviewer, :payment_agreement_auditor, :auditor
         ]
    item :credit_notes, create: true
    item :utility_subscriptions, create: true
    item :users, create: true, permissions: [:admin]
  end

  item :download_manager, icon: "https://img.icons8.com/windows/22/ffffff/software-installer.png"

end