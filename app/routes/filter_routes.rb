Filters::Router.draw do
  # Master
  route 'vendors', Masters::Vendors::FilterConfig

  # Docs
  route 'invoices', Docs::P2P::Invoices::FilterConfig
  route 'purchase_requests', Docs::P2P::PurchaseRequests::FilterConfig
  route 'purchase_orders', Docs::P2P::PurchaseOrders::FilterConfig
  route 'utility_bills', Docs::UtilityBills::Bills::FilterConfig
end
