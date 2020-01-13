class Admin::Implementations::Master::BankAccounts::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bank_accounts.export'

  headers ({
      :id => "ID",
      :account_name => "Bank Name",
      :user_id => "User Email / Mobile NUmber",
      :account_number => "Account Number",
      :ifsc => "IFSC",
      :destroy => "Destroy"
  })

  def valid_request

  end

  def input
    BankAccount.where(:account_owner_id => company.users.pluck(:id),
                                :account_owner_type => "User",
                                :company_id => company.id)
  end

  def id(bank_account)
    bank_account.id
  end

  def account_name(bank_account)
    bank_account.name
  end

  def user_id(bank_account)
    bank_account.account_owner.mobile_number
  end

  def account_number(bank_account)
    "'#{bank_account.account_number}"
  end

  def ifsc(bank_account)
    bank_account.ifsc
  end

  def destroy(bank_account)
   ""
  end

  def post_process
  end

end
