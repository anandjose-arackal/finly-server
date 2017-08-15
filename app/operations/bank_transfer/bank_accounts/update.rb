class BankTransfer::BankAccounts::Update < BankTransfer::BankAccounts::Base

  attr_accessor :account_params

  def init
    id = params[:id] || params[:bank_account_id]
    self.bank_account = BankAccount.find_by(id: id)
    self.account_params = bank_account_params
  end

  def pre_process

  end

  def process
    unless bank_account.update(account_params)
      add_message :error, bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank Account updated"
  end

end