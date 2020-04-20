IndexBuilder::Router.draw do
  # Masters
  route "vendors", Masters::Vendors::Index
  route "items", Masters::Items::Index

  # Docs
  route "invoices", Docs::P2P::Invoices::Index
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Index
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Index
  route 'po_advances', Docs::P2P::PurchaseOrders::Advances::Index
  route 'utility_bills', Docs::UtilityBills::Bills::Index
  route 'payment_tickets', Docs::PaymentTickets::Index
  route 'payments', Docs::PaymentTickets::Payments::Index
  # route 'beneficiary_payments', Docs::P2P::BeneficiaryPayment::Index
  route 'upcoming_invoices', Docs::P2P::Invoices::Agreement::UpcomingInvoices::Index
end