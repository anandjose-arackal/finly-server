class Appsmith::Companies::VirtualAccounts::Create < Transactions::API

  schema do
    params do
      required(:company_id)
    end
  end

  user_model(AdminUser)

  step :execute_background_job

  def execute_background_job(context, params:, **)
    VirtualBankAccounts::Create::Background.call_async( params: params)
    true
  end
end
