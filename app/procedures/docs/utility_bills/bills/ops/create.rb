class Docs::UtilityBills::Bills::Ops::Create < Transactions::API

  step Model(BbpsBill, :new)
  # step Policy::Pundit( Docs::UtilityBills::Bills::Authorizer, :create? )
  step :set_default_params
  step Contract::Build(constant: Docs::UtilityBills::Bills::Contracts::Base)
  failure :check_0
  step Contract::Validate(key: 'bill')

  failure :check
  step Contract::Persist()

  def check(options, **)
  end

  def check_0(options, **)
  end

  def authorize_user_presence!(options)
    true
  end

  def set_default_params(options, params:, **)
    # todo need to come from cron
    bbps_biller_subscription = BbpsBillerSubscription.find_by id: params[:subscription_id]

    bill = bbps_biller_subscription.attributes.slice('subscription_id', 'department_id', 'cost_center_id', 'location_id')
    bill['subscription_id'] = bbps_biller_subscription.id

    params['bill'] = bill
    params['bill']['amount'] = {value: params[:amount][:value], currency_id: params[:amount][:currency_id]}
    true
  end
end
