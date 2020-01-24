class Docs::P2P::CreditNotes::Ops::Destroy < Transactions::API

  step Model(CreditNote, :find_by)
  step Policy::Pundit(Docs::P2P::CreditNotes::Authorizer, :destroy?)

  step :destroy!
  step Transactions::Messages::SuccessMessage('Successfully Deleted Credit Note')

  def destroy!(options, model:, **)
    model.destroy
  end
end