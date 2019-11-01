class Docs::UtilityBills::Subscriptions::Ops::Approve < Transactions::API

  step Model( BbpsBillerSubscription, :find_by )
  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :approve? )
  step :set_default_params
  step Contract::Build( constant: Docs::UtilityBills::Subscriptions::Contracts::Base )
  step Contract::Validate(key: 'subscription')

  failure :check
  step Contract::Persist()

  def check(params, **)
    # debugger
  end

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:user_id] = current_user&.id
    params[:subscription][:current_user] = current_user
  end
end