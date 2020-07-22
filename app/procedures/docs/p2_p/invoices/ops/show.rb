class Docs::P2P::Invoices::Ops::Show < Transactions::API

  step Model(Invoice, :find_by_id)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :show?)

end