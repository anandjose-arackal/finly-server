IndexBuilder::Router.draw do
  route "invoices_po", Docs::P2P::Invoices::PoInvoicesIndex
  route "invoices_non_po", Docs::P2P::Invoices::NonPoInvoicesIndex
  route "invoices_agreement", Docs::P2P::Invoices::AgreementInvoicesIndex
end