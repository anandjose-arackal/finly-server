# Since the bank accounts are soft deletable, just mark them as deleted in this operation

class BankTransfer::BankAccounts::Destroy < BankTransfer::BankAccounts::Base

  attr_accessor :bank_account

  def init
    id = params[:id] || params[:bank_account_id]
    self.bank_account = user.bank_accounts.find_by(id: id)
  end

  def process
    unless self.bank_account.destroy
      add_message :error, bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank account deleted"
  end
end