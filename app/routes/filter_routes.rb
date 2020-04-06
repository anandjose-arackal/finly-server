Filters::Router.draw do
  route 'invoices_po', Docs::P2P::Invoices::Po::FilterConfig
  route 'invoices_non_po', Docs::P2P::Invoices::NonPo::FilterConfig
  route 'invoices_agreement', Docs::P2P::Invoices::Agreement::FilterConfig
  route 'vendors', Docs::P2P::Vendors::FilterConfig
end
