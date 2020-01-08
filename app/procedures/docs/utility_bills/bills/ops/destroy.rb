class Docs::UtilityBills::Bills::Ops::Destroy < Transactions::API

  step Model(BbpsBill, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Bills::Authorizer, :destroy?)

  step :destroy!
  step Transactions::Messages::SuccessMessage('Successfully Deleted Utility Bill')

  def destroy!(options, model:, **)
    model.destroy
  end
end