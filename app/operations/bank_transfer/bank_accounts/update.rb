class BankTransfer::BankAccounts::Update < BankTransfer::BankAccounts::Base

  attr_accessor :account_params, :set_default_account

  def init
    id = params[:id] || params[:bank_account_id]
    self.bank_account = BankAccount.find_by(id: id)
    self.account_params = bank_account_params
  end

  def validate
    # self.is_default_account = bank_account.default_account
    if bank_account.default_account == true && account_params[:default_account] == "0"
      add_message :error, "You need to have one default account. Please mark any other account as default before you proceed"
    end
  end

  def pre_process
    self.set_default_account = false
    if bank_account.default_account == false && account_params[:default_account] == "1"
      # Flag set whether to update all other bank accounts as NOT default
      self.set_default_account = true
    end
  end

  def process
    bank_account.assign_attributes(account_params)
    if bank_account.valid?
      if set_default_account
      #   Set all accounts as NOT default
        bank_account.account_owner.bank_accounts.update_all(default_account: false)
      end

      bank_account.save
    else
      add_message :error, bank_account.errors.full_messages
    end

  end

  def post_process
    add_message :success, "Bank Account updated"
  end

end