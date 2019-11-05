class Docs::UtilityBills::Subscriptions::Ops::Review < Transactions::API
  cattr_accessor :aasm_event

  step :init
  step Model(BbpsBillerSubscription, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Subscriptions::Authorizer, :submit?)
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Subscriptions::Contracts::Base)
  step Contract::Validate(key: 'subscription')

  failure :check

  def init(options, params:, **)
    @@aasm_event = (params[:aasm_event].to_s + '?')
  end

  def check(params, **)
  end
end