class Docs::UtilityBills::Bills::Ops::Create < Transactions::API

  step Model(BbpsBill, :new)
  # step Policy::Pundit( Docs::UtilityBills::Bills::Authorizer, :create? )
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Base)
  failure :check
  step Contract::Validate(key: 'bill')
  failure :check1

  step Contract::Persist()
  failure :check2


  def check(options, model:, **)
  end

  def check1(options, model:, **)
  end

  def check2(options, model:, **)
  end

  def authorize_user_presence!(options)
    true
  end

  def set_default_params(options, params:, **)
    subscription = BbpsBillerSubscription.find_by id: params[:subscription_id]
    bill = subscription.attributes.slice('policy_id', 'department_id', 'location_id', 'cost_center_id', 'company_id')
    bill['subscription_id'] = subscription.id

    bill['amount'] = {
        value: params[:amount] || 0,
        currency_id: 1 # Hard coded for now
    }

    params['bill'] = bill
  end
end
