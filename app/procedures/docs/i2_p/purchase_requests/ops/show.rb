class Docs::I2P::PurchaseRequests::Ops::Show < Transactions::API

  step Model(PurchaseRequest, :find_by)
  step Policy::Pundit(Docs::P2P::PurchaseRequests::Policy, :show?)
  step Forms::Model::Find()

end