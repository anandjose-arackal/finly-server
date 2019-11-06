class Docs::UtilityBills::Bills::Ops::Create < Transactions::API

  step Model(BbpsBill, :new)
  # step Policy::Pundit( Docs::UtilityBills::Bills::Authorizer, :create? )
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Base)
  step Contract::Validate(key: 'bill')

  step Contract::Persist()


  def authorize_user_presence!(options)
    true
  end

  def set_default_params(options, params:, **)
    subscription = BbpsBillerSubscription.find_by id: params[:subscription_id]
    bill = subscription.attributes.slice('policy_id', 'department_id', 'location_id', 'cost_center_id', 'company_id')
    bill['subscription_id'] = subscription.id

    bill['amount'] = {
        value: params[:amount],
        currency_id: 1 # Hard coded for now
    }

    params = {
        'bill' => bill,
        'subscription_id': subscription.id
    }
  end
end
