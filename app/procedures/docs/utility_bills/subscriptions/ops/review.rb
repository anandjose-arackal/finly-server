class Docs::UtilityBills::Subscriptions::Ops::Review < Transactions::API

  # schema do
  #   params do
  #     required('aasm_event')
  #   end
  # end

  step :init
  step Model(BbpsBillerSubscription, :find_by)
  step :verify_policy
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Base)
  step Contract::Validate(key: 'subscription')

  failure :check

  def init(options, params:, **)
    params[:id] = params[:subscription_id]

  end

  def verify_policy(options, current_user:, params:, model:, **)
    policy = Docs::UtilityBills::Subscriptions::Authorizer.new(current_user, model)

    success = policy.send((params['aasm_event'].to_s + '?').to_sym)

    unless success
      return false
    end

    true
  end


  def check(options, params:, **)
  end
end