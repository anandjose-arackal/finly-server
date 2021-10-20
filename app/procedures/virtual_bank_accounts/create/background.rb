class VirtualBankAccounts::Create::Background < Transactions::API

  include Transactions::BackgroundWorker

  skip_user_authorization!

  step :perform_job!

  def perform_job!(context, params:, **)
    puts " ----------------------------- PERFORMING VIRTUAL ACCOUNT CREATION at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------ "
    ActsAsTenant.current_tenant = Company.find(params[:company_id])
    UtilityBillsAccount.find_by(company_id: params[:company_id]).va_generate
    puts " ----------------------------- FINISHED ------------------------------ "
  end
end
