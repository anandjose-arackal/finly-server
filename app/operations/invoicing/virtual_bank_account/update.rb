# most likely not necessary, because once created it can only be marked as inactive or destroyed

class Invoicing::VirtualBankAccount::Update < Invoicing::VirtualBankAccount::Base

  def validate
    if self.virtual_bank_account.blank?
      add_message :error, "Bank account not found"
    end
  end

  def process
    unless self.virtual_bank_account.update(virtual_bank_account_params)
      add_message :error, self.virtual_bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank Account updated"
  end

  private

  def virtual_bank_account_params
    params.require(:virtual_bank_account).permit(:expires_by, :description, :name)
  end

end