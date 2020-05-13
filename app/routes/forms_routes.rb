Forms::Router.draw do
  # route 'trips', Docs::Trips::Form
  route 'vendors', Masters::Vendors::Form
  route 'test', Forms::TestForm
end
