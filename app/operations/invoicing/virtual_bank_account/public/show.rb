class Invoicing::VirtualBankAccount::Public::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account

  def init
    acc_number = params[:virtual_account_number]
    self.virtual_bank_account = ::VirtualBankAccount.find_by(account_number: acc_number)
  end

  def process

  end

  def success
    params[:virtual_bank_account] = self.virtual_bank_account
    Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter.new(user, params, messages)
  end

end