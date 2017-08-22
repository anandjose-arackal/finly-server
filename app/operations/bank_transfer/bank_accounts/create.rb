class BankTransfer::BankAccounts::Create < BankTransfer::BankAccounts::Base

  attr_accessor :bank_account, :account_params, :owner

  def pre_validate
    super()
    if params[:beneficiary_type].blank? || params[:beneficiary_id].blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.account_params = bank_account_params
    case params[:beneficiary_type]
      when "User"
        self.owner = User.find_by(id: params[:beneficiary_id])
      when "YesBankVendor"
        self.owner = YesBankVendor.find_by(id: params[:beneficiary_id])
      else
        # do nothing?
    end
  end

  def pre_process

  end

  def validate
    if owner.blank?
      add_message :error, "Account owner not found"
    end
  end

  def process
    self.bank_account = self.owner.bank_accounts.build(account_params)
    unless bank_account.save
      add_message :error, bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank account ceated!"
  end
end

