class Docs::I2P::PurchaseOrders::Ops::Show < Transactions::API

  step Model(PurchaseOrder, :find_by)
  step Policy::Pundit(Docs::P2P::PurchaseOrders::Policy, :show?)
  step Forms::Model::Find()

end