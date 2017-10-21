class Invoicing::VirtualBankAccount::Reactivate < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account

  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = user.company.virtual_bank_accounts.find_by(id: id)
  end

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Bank account number not found"
      return
    end
  end

  def process
    unless self.virtual_bank_account.reactivate
      add_message :error, virtual_bank_account.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Virtual Bank Account reactivated"
  end
end