class Docs::I2P::CreditNotes::Ops::Show < Transactions::API

  step Model(CreditNote, :find_by)
  # step Policy::Pundit(Docs::P2P::CreditNotes::Policy, :show?)
  step Forms::Model::Find()

end