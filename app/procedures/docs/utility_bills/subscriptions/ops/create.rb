class Docs::UtilityBills::Subscriptions::Ops::Create < Trailblazer::Operation

  step Model( BbpsBillerSubscription, :new )
  step Policy::Pundit( Docs::UtilityBills::Subscriptions::Authorizer, :create? )
  step :set_default_params
  step Contract::Build( constant: Docs::UtilityBills::Subscriptions::Contracts::Base )
  step Contract::Validate(key: 'subscription')

  failure :check
  step Contract::Persist()

  def check(params, **)
    debugger
  end

  def set_default_params(options, params:, current_user:, **)
    # Set Initiator
    params[:subscription][:user_id] = current_user&.id
    params[:subscription][:current_user] = current_user
  end
end