class BankTransfer::BankAccount::Create < BankAccount::Base

  attr_accessor :bank_account, :account_params

  def pre_validate
    super()
  end

  def init
    self.account_params = bank_account_params
  end

  def validate

  end

  def process
    self.bank_account = BankAccount.new(account_params)
    unless bank_account.save
      add_message :error, bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank account ceated!"
  end
end
