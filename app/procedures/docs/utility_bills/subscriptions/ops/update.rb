class Docs::UtilityBills::Subscriptions::Ops::Update < Trailblazer::Operation

  step Model( BbpsBillerSubscription, :find )
  step Policy::Pundit( UtilityBills::Subscriptions::Authorizer, :update? )
  # step :set_default_params
  step Contract::Build( constant: UtilityBills::Subscriptions::Contracts::Base )
  step Contract::Validate(key: 'subscription')
  failure :check
  step Contract::Persist()

  def check(params, **)
    debugger
  end

  def set_default_params(options, params:, current_user:, **)
    # Set Initiator
    params[:subscription][:user_id] = current_user&.id
  end

end