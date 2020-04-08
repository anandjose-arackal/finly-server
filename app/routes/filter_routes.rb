Filters::Router.draw do
  # Master
  route 'vendors', Masters::Vendors::FilterConfig

  # Docs
  route 'invoices_po', Docs::P2P::Invoices::Po::FilterConfig
  route 'invoices_non_po', Docs::P2P::Invoices::NonPo::FilterConfig
  route 'invoices_agreement', Docs::P2P::Invoices::Agreement::FilterConfig
  route 'purchase_requests', Docs::P2P::PurchaseRequests::FilterConfig
  route 'purchase_orders', Docs::P2P::PurchaseOrders::FilterConfig
end
