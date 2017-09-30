# Since the bank accounts are soft deletable, just mark them as deleted in this operation

class BankTransfer::BankAccounts::Destroy < BankTransfer::BankAccounts::Base

  attr_accessor :bank_account, :account_owner

  def init
    id = params[:id] || params[:bank_account_id]
    case params[:view]
      when "admin"
        self.bank_account = user.company.bank_accounts.find_by(id: id)
      else
        self.bank_account = user.bank_accounts.find_by(id: id)
    end
    if bank_account.present?
      self.account_owner = self.bank_account.account_owner
    end
  end

  def validate
    if bank_account.blank?
      add_message :error, "Bank account not found"
      return
    end
  end

  def process
    unless self.bank_account.update(is_deleted: true)
      add_message :error, bank_account.errors.full_messages
    end
  end

  def post_process
    # checking if the account owner has any default accounts, if not set one of them
    unless self.account_owner.bank_accounts.default_accounts.present?
      self.account_owner.bank_accounts.non_deleted.first.update(default_account: true)
    end

    add_message :success, "Bank account deleted"
  end
end