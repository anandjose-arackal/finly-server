class BankTransfer::PaymentRequest::Base < BaseOperation

  attr_accessor :initiating_account, :role_id

  def authorized_user_types
    [:vendor_payments_admin, :vendor_payments_reviewer, :vendor_payments_creditor, :vendor_payments_initiator, :auditor]
  end

  def pre_validate
    return unless user_present?
    params_present?
  end

  def init
    super
    self.role_id = params[:role_id]
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