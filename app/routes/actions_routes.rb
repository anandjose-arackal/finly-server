ActionManager::Router.draw do

  # Masters
  route 'vendors', Masters::Vendors::Action

  # Docs
  route 'invoices_po', Docs::P2P::Invoices::Po::Action
  route 'invoices_non_po', Docs::P2P::Invoices::NonPo::Action
  route 'invoices_agreement', Docs::P2P::Invoices::Agreement::Action
  route 'purchase_requests', Docs::P2P::PurchaseRequests::Action
end