Forms::Router.draw do
  # route 'trips', Docs::Trips::Form
  route 'vendors', Masters::Vendors::Form
  route 'test', Forms::TestForm
  route 'non_po_invoice', Docs::P2P::Invoices::NonPo::Form
  route 'invoices', Docs::P2P::Invoices::NonPo::Form
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Form
end
