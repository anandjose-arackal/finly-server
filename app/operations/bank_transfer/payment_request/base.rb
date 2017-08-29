class BankTransfer::PaymentRequest::Base < BaseOperation

  attr_accessor :initiating_account

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def retrieve_initiating_account
    if user.company_admin? && params[:initiating_account_type]
      case params[:initiating_account_type]
        when 1, '1', "CompanyAccount"
          self.initiating_account = user.company.yes_bank_company_account
        when 2, '2', "FinlyCredits"
          self.initiating_account = user.bank_wallet
        else
          # do nothing?
      end
    else
      self.initiating_account = user.bank_wallet
    end
  end

  def retrieve_balance(account, user)
    if account.blank? || user.blank?
      return 0
    end
    case account
      when :vendor_payment_wallet
        adapter = AccountManager::BankWallet::VendorPaymentWalletAdapter.new(user.bank_wallet)
        return adapter.balance
    end
  end

end