IndexBuilder::Router.draw do
  route "invoices_po", Docs::P2P::Invoices::Po::Index
  route "invoices_non_po", Docs::P2P::Invoices::NonPo::Index
  route "invoices_agreement", Docs::P2P::Invoices::Agreement::Index
  route "vendors", Masters::Vendors::Index
end