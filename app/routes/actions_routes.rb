ActionManager::Router.draw do

  route 'invoices_po', Docs::P2P::Invoices::Po::Action
  route 'invoices_non_po', Docs::P2P::Invoices::NonPo::Action
  route 'invoices_agreement', Docs::P2P::Invoices::Agreement::Action
  route 'vendors', Docs::P2P::Vendors::Action

end