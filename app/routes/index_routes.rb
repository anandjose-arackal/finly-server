IndexBuilder::Router.draw do

  scope 'admin' do
    route 'macros', Admin::Masters::Macros::Ops::Index
    route 'macro_jobs', Admin::Masters::Macros::Jobs::Index
  end

  # Masters
  route "vendors", Masters::Vendors::Index
  route "items", Masters::Items::Index
  route 'users', Masters::Users::Index
  route 'rate_contracts', Masters::RateContracts::Index
  route 'utility_subscriptions', Docs::UtilityBills::Subscriptions::Index
  route 'agreements', Docs::P2P::Agreements::Index

  # Docs
  route "invoices", Docs::P2P::Invoices::Index
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Index
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Index
  route 'po_advances', Docs::P2P::PurchaseOrders::Advances::Index
  route 'utility_bills', Docs::UtilityBills::Bills::Index
  route 'payment_tickets', Docs::PaymentTickets::Index
  route 'payments', Docs::PaymentTickets::Payments::Index
  route 'upcoming_invoices', Docs::P2P::Invoices::Agreement::UpcomingInvoices::Index
  route 'receive', Docs::P2P::Inwards::Pending::Index
  route 'receive_history', Docs::P2P::Inwards::Received::Index
  route 'credit_notes', Docs::P2P::CreditNotes::Index
end