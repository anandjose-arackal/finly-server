class Docs::UtilityBills::Subscriptions::Configs::BillerFields < Transactions::API

  schema do
    params do
      optional(:biller_id).filled
    end
  end

  step :init

  def init(options, params:, current_user:, **)
    biller_id = params[:biller_id]
    biller_op = Docs::UtilityBills::Billers::Ops::Show.(params: {id: biller_id}, "current_user" => current_user)

    bbps_biller = biller_op['model']

    options['result'] = {}
    options['result']['model'] = bbps_biller
    options['result']['fetch_requirement'] = biller_op['model']&.fetch_requirement
    options['result']['support_bill_validation'] = biller_op['model']&.support_bill_validation
    true
  end
end