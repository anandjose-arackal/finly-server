class Docs::P2P::Invoices::Show < Transactions::API

  step Form(route: 'invoices')
  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :show?)
  step Forms::Contracts::Build()

end