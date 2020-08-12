Masters::Router.draw do
  # route 'trips', Docs::Trips::Form
  route 'categories', Masters::Categories::Master
  route 'items', Masters::Items::Master
end
