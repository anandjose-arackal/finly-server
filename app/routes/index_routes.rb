IndexBuilder::Router.draw do
  # Masters
  route "vendors", Masters::Vendors::Index

  # Docs
  route "invoices", Docs::P2P::Invoices::Index
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Index
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Index
end