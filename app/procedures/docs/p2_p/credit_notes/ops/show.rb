class Docs::P2P::CreditNotes::Ops::Show < Transactions::API
  # Find model by ID
  step Model(CreditNote, :find_by)

  # Pass the model to the policy and check if user can perform the action
  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :show?)
end


# Logics
# 1. If invoice already has a credit note
# 2. By Default calculate revised rate as inclusive of discount