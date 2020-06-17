class Docs::UtilityBills::Subscriptions::Ops::AddBill < Transactions::API

  step :init
  step Model(BbpsBillerSubscription, :find_by)
  step Policy::Pundit(Docs::UtilityBills::Subscriptions::Authorizer, :add_bill?)
  # step :set_default_params
  fail :check
  step :create_bill
  step Transactions::Messages::SuccessMessage('Added Bill Successfully')

  def init(options, params:, **)
    params[:id] = params[:subscription_id]
  end


  def check(options, **)
  end

  def create_bill(options, model:, current_user:, **)
    options['result'] = {}
    params = {
        subscription_id: model.id,
        'bill' => {}
    }

    op = Docs::UtilityBills::Bills::Ops::Create.(params: params, current_user: current_user)

    if op.success?
      options['result'] = {'bill' => op['model']}
      options['result']['bill']['autofetched'] = true
    end
    options

    op.success?
  end

  def set_default_params(options, params:, current_user:, **)
    params[:subscription][:user_id] = current_user&.id
    params[:subscription][:current_user] = current_user
  end
end