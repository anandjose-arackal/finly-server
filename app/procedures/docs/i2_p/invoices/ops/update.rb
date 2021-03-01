class Docs::I2P::Invoices::Ops::Update < Transactions::API

  step Model(Invoice, :find_by)
  step Policy::Pundit(Docs::I2P::Invoices::Policy, :update?)
  step FindForm()
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Invoice Updated')

end