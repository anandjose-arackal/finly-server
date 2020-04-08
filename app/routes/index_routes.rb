IndexBuilder::Router.draw do
  # Masters
  route "vendors", Masters::Vendors::Index

  # Docs
  route "invoices_po", Docs::P2P::Invoices::Po::Index
  route "invoices_non_po", Docs::P2P::Invoices::NonPo::Index
  route "invoices_agreement", Docs::P2P::Invoices::Agreement::Index
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Index
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Index
end