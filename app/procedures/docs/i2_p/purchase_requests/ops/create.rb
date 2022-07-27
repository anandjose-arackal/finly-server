class Docs::I2P::PurchaseRequests::Ops::Create < Transactions::API

  step Form(route: 'purchase_requests')
  step Model(PurchaseRequest, :new)
  step Policy::Pundit(Docs::P2P::PurchaseRequests::Policy, :create?)
  step Forms::Contracts::Build()
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Saved')

end