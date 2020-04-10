ActionManager::Router.draw do

  # Masters
  route 'vendors', Masters::Vendors::Action

  # Docs
  route 'invoices', Docs::P2P::Invoices::Action
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Action
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Action
end