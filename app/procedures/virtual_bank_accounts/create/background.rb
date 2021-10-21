class VirtualBankAccounts::Create::Background < Transactions::API
  include Transactions::BackgroundWorker
  sidekiq_options queue: :payments_critical_queue

  skip_user_authorization!

  step :create_va_account!

  def create_va_account!(context, params:, **)
    puts " ----------------------------- PERFORMING VIRTUAL ACCOUNT CREATION at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------ "
    ActsAsTenant.current_tenant = Company.find(params[:company_id])
    UtilityBillsAccount.find_by(company_id: params[:company_id]).va_generate
    puts " ----------------------------- FINISHED ------------------------------ "
  end
end
