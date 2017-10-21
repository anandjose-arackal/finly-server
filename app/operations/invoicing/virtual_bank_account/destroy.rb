# this operation either marks the virtual account as inactive or destroys it entirely
# marking as inactive will happen if the bank account has even one associated payments with it

class Invoicing::VirtualBankAccount::Destroy < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account, :payments_received

  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = user.company.virtual_bank_accounts.find_by(id: id)
    self.payments_received = Payment.where(initiating_account: self.virtual_bank_account)
  end

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Bank account number not found"
      return
    end
    unless self.payments_received.empty?
      add_message :error, "This account has payments associated with it - cannot be destroyed at this time"
    end
  end

  def process
    unless self.virtual_bank_account.destroy
      add_message :error, virtual_bank_account.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Virtual Bank Account destroyed"
  end
end