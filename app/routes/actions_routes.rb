ActionManager::Router.draw do
  # NavBar
  route 'procurement', Menu::Masters::Procurement

  # Masters
  route 'vendors', Masters::Vendors::Action
  route 'items', Masters::Items::Action
  route 'users', Masters::Users::Action
  route 'rate_contracts', Masters::RateContracts::Action

  # Docs
  route 'invoices', Docs::P2P::Invoices::Action
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Action
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Action
  route 'po_advances', Docs::P2P::PurchaseOrders::Advances::Action
  route 'utility_bills', Docs::UtilityBills::Bills::Action
  route 'payment_tickets', Docs::PaymentTickets::Action
  route 'payments', Docs::PaymentTickets::Payments::Action
  route 'upcoming_invoices', Docs::P2P::Invoices::Agreement::UpcomingInvoices::Action
  route 'receive', Docs::P2P::Inwards::Pending::Action
  route 'receive_history', Docs::P2P::Inwards::Received::Action
end