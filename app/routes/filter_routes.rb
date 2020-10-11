Filters::Router.draw do

  scope :admin do
    route 'macros', Admin::Masters::Macros::FilterConfig
    route 'macro_jobs', Admin::Masters::Macros::Jobs::FilterConfig
  end

  # Master
  route 'vendors', Masters::Vendors::FilterConfig
  route 'items', Masters::Items::FilterConfig
  route 'users', Masters::Users::FilterConfig
  route 'rate_contracts', Masters::RateContracts::FilterConfig
  route 'utility_subscriptions', Docs::UtilityBills::Subscriptions::FilterConfig
  route 'agreements', Docs::P2P::Agreements::FilterConfig

  # Docs
  route 'invoices', Docs::P2P::Invoices::FilterConfig
  route 'purchase_requests', Docs::P2P::PurchaseRequests::FilterConfig
  route 'purchase_orders', Docs::P2P::PurchaseOrders::FilterConfig
  route 'po_advances', Docs::P2P::PurchaseOrders::Advances::FilterConfig
  route 'utility_bills', Docs::UtilityBills::Bills::FilterConfig
  route 'payment_tickets', Docs::PaymentTickets::FilterConfig
  route 'payments', Docs::PaymentTickets::Payments::FilterConfig
  route 'upcoming_invoices', Docs::P2P::Invoices::Agreement::UpcomingInvoices::FilterConfig
  route 'receive', Docs::P2P::Inwards::Pending::FilterConfig
  route 'receive_history', Docs::P2P::Inwards::Received::FilterConfig
  route 'credit_notes', Docs::P2P::CreditNotes::FilterConfig
end
