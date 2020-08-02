Forms::Router.draw do
  # route 'trips', Docs::Trips::Form
  route 'vendors', Masters::Vendors::Form
  route 'test', Forms::TestForm
  route 'invoices', Docs::P2P::Invoices::Form
end
