HoverCard::Router.draw do

  # Masters
  route 'users', Masters::Users::HoverCard
  route 'masters.*', Masters::Schema::Records::HoverCard

  # Docs

end