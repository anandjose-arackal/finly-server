class Invoicing::VirtualBankAccount::Show < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account

  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = Invoicing::VirtualBankAccount::Index.(user, params).virtual_bank_accounts.find_by(id: id) rescue nil
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