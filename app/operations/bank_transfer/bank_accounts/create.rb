class BankTransfer::BankAccounts::Create < BankTransfer::BankAccounts::Base

  attr_accessor :bank_account, :account_params, :owner, :set_default_account

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
    if account_params[:default_account] == '1'
      self.set_default_account = true
    end
  end

  def validate
    if owner.blank?
      add_message :error, "Account owner not found"
    end
  end

  def process
    self.bank_account = self.owner.bank_accounts.build(account_params)

    if bank_account.valid?
      if set_default_account
        owner.bank_accounts.update_all(default_account: false)
      end
    end

    unless bank_account.save
      add_message :error, bank_account.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Bank account ceated!"
  end
end

