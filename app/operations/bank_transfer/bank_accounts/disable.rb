class BankTransfer::BankAccounts::Disable < BankTransfer::BankAccounts::Base

  attr_accessor :bank_accounts

  def init
    account_number = params[:account_number]
    self.bank_accounts = user.company.bank_accounts.with_account_number(account_number)
  end

  def validate
    if self.bank_accounts.empty?
      add_message :error, "Bank account not found"
      return
    end
  end

  def process
    unless self.bank_accounts.update_all(disabled: true)
      add_message :error, self.bank_account.errors.full_messages
    end
  end

  def success
    params[:bank_accounts] = self.bank_accounts
    BankTransfer::BankAccounts::Base::BankAccountPresenter.new(user, params, messages)
  end
end