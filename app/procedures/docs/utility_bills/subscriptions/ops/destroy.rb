class Docs::UtilityBills::Subscriptions::Ops::Destroy < Transactions::API

  step Model(BbpsBillerSubscription, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Subscriptions::Authorizer, :destroy?)

  step :destroy!
  step Transactions::Messages::SuccessMessage('Successfully Deleted Utility Bill Master')

  def destroy!(options, model:, **)
    model.destroy
  end
end