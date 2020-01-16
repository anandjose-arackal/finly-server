class Docs::UtilityBills::Subscriptions::Ops::Update < Transactions::API

  step :set_default_params

  step Model(BbpsBillerSubscription, :find_by)

  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :update? )

  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Update)

  step Contract::Validate(key: 'subscription')

  step Contract::Persist()

  step Transactions::Messages::SuccessMessage('Successfully Updated Utility Bill Master')

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:current_user] = current_user
  end
end