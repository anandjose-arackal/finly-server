Filters::Router.draw do
  # Master
  route 'vendors', Masters::Vendors::FilterConfig
  route 'items', Masters::Items::FilterConfig
  route 'item_master', Masters::Items::FilterConfig
  route 'users', Masters::Users::FilterConfig

  # Docs
  route 'invoices', Docs::P2P::Invoices::FilterConfig
  route 'purchase_requests', Docs::P2P::PurchaseRequests::FilterConfig
  route 'purchase_orders', Docs::P2P::PurchaseOrders::FilterConfig
  route 'po_advances', Docs::P2P::PurchaseOrders::FilterConfig
  route 'utility_bills', Docs::UtilityBills::Bills::FilterConfig
  route 'payment_tickets', Docs::PaymentTickets::FilterConfig
  route 'payments', Docs::PaymentTickets::Payments::FilterConfig
  route 'upcoming_invoices', Docs::P2P::Invoices::Agreement::UpcomingInvoices::FilterConfig
  route 'receive', Docs::P2P::PurchaseOrders::Receipts::Pending::FilterConfig
end
