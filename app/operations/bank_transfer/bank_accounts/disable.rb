class BankTransfer::BankAccounts::Disable < BankTransfer::BankAccounts::Base

  attr_accessor :bank_account

  def init
    account_number = params[:account_number]
    self.bank_account = user.company.bank_accounts.find_by(account_number: account_number)
  end

  def process
    unless self.bank_account.update(disabled: true)
      add_message :error, self.bank_account.errors.full_messages
    end
  end

  def success
    params[:bank_account] = self.bank_account
    BankTransfer::BankAccounts::Base::BankAccountPresenter.new(user, params, messages)
  end
end