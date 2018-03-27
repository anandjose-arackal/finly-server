class Invoicing::VirtualBankAccount::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account

  def init
    super
    if self.virtual_bank_account.blank?
      number = params[:account_number]
      op = Invoicing::VirtualBankAccount::Index.(user, params)
      self.virtual_bank_account = op.virtual_bank_accounts.find_by(account_number: number)
    end
  end

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Bank Account not found"
    end
  end

  def process

  end

  def success
    params[:virtual_bank_account] = self.virtual_bank_account
    Invoicing::VirtualBankAccount::Base::VirtualAccountPresenter.new(user, params, messages)
  end
end