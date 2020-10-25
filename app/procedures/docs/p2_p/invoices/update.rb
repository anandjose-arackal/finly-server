class Docs::P2P::Invoices::Update < Transactions::API

  step Form(route: 'invoices')
  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::P2P::Invoices::Policy, :update?)
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Saved')

end