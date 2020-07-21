class Docs::P2P::Invoices::Ops::Update < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :update?)
  step Contract::Build(constant: Docs::P2P::Invoices::Contracts::Update)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Invoice saved')

end