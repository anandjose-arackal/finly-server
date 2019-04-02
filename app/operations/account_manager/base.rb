class AccountManager::Base < BackgroundOperation
  sidekiq_options queue: :payments_queue

  def user_model
    [User, AdminUser]
  end

  protected

  def retrieve_adapter(account, payment = nil)
    acc_type = account&.class&.to_s
    case acc_type
      when 'Card'
        return AccountManager::Cards::CardAdapter.new(account, payment)
      when 'UserWallet'
        return AccountManager::Wallet::WalletAdapter.new(account, payment)
      when 'YesBankCompanyAccount'
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(account, payment)
      when 'CashOnHand'
        return AccountManager::CashOnHand::CashOnHandAdapter.new(account, payment)
      when 'ItzCashCompanyAccount'
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(account, payment)
      when 'BankAccount'
        return AccountManager::BankAccount::BankAccountAdapter.new(account, payment)
      when 'VendorPaymentWallet'
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(account, payment)
      when 'UserPocket'
        return AccountManager::CashPockets::UserPocketsAdapter.new(account, payment)
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end

end