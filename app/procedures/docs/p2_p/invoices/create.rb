class Docs::P2P::Invoices::Create < Transactions::API

  step Form(route: 'invoices')
  step Model(Invoice, :new)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :create?)
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Saved')

end