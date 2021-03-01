class Docs::I2P::Invoices::Ops::Show < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :show?)
  step FindForm()

end