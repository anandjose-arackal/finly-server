Forms::Router.draw do
  # route 'trips', Docs::Trips::Form
  route 'vendors', Masters::Vendors::Form
  route 'test', Forms::TestForm
  route 'non_po_invoice', Docs::P2P::Invoices::NonPo::Form
  
  route 'po_invoice', Docs::P2P::Invoices::Po::Form
  route 'po_invoices', Docs::P2P::Invoices::Po::Form
  route 'tax_invoice', Docs::P2P::Invoices::Po::Form

  route 'invoices', Docs::P2P::Invoices::NonPo::Form
  route 'purchase_orders', Docs::P2P::PurchaseOrders::Form
  route 'po', Docs::P2P::PurchaseOrders::Form
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Form

  route 'credit_notes', Docs::P2P::CreditNotes::Form
end
