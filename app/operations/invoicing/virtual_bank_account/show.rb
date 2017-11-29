class Invoicing::VirtualBankAccount::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account

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