class Invoicing::VirtualBankAccount::Deactivate < Invoicing::VirtualBankAccount::Base

  attr_accessor :virtual_bank_account

  def init
    id = params[:id] || params[:virtual_bank_account_id]
    self.virtual_bank_account = user.company.virtual_bank_accounts.find_by(id: id)
    if self.virtual_bank_account.blank?
      number = params[:account_number]
      op = Invoicing::VirtualBankAccount::Index.(user, params)
      self.virtual_bank_account = op.virtual_bank_accounts.find_by(account_number: number)
    end
  end

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Bank account number not found"
      return
    end
  end

  def process
    if self.virtual_bank_account.deactivate
      # deactivate the account in the collect server as well
      op = FinlyCollect::MakeInactive.(user, account_number: virtual_bank_account.account_number)
      unless op.success?
        virtual_bank_account.reactivate
        add_message :error, "Account could not be deactivated at this time. Try again later"
      end
    else
      add_message :error, virtual_bank_account.errors.full_messages
      return
    end
  end

  def post_process
    add_message :success, "Virtual Bank Account deactivated"
  end
end