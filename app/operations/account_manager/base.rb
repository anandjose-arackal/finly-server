class AccountManager::Base < BackgroundOperation

  def user_model
    [User, AdminUser]
  end

  protected

  def retrieve_adapter(account)
    acc_type = account&.class&.to_s
    case acc_type
      when 'Card'
        return AccountManager::Cards::CardAdapter.new(account)
      when 'UserWallet'
        return AccountManager::Wallet::WalletAdapter.new(account)
      when 'YesBankCompanyAccount'
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(account)
      when 'CashOnHand'
        return AccountManager::CashOnHand::CashOnHandAdapter.new(account)
      when 'ItzCashCompanyAccount'
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(account)
      when 'BankAccount'
        return AccountManager::BankAccount::BankAccountYesBankAdapter.new(account)
      when 'VendorPaymentWallet'
        return AccountManager::BankAccount::VendorPaymentWalletAdapter.new(account)
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end

end