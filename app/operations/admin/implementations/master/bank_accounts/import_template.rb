class Admin::Implementations::Master::BankAccounts::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bank_accounts.import_template'
  headers ({
              :id => "ID",
              :name => "Bank Name",
              :user_id => "User Email / Mobile NUmber",
              :account_number => "Account Number",
              :ifsc => "IFSC",
              :destroy => "Destroy"
  })

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
