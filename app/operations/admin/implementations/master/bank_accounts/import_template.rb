class Admin::Implementations::Master::BankAccounts::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bank_accounts.import_template'
  headers [
              :name,
              :user_id,
              :account_number,
              :ifsc
          ]

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

end
