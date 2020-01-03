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
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(account)
      when 'KotakBankCompanyAccount'
        return AccountManager::KotakBankAccount::KotakBankCompanyAccountAdapter.new(account)
      when 'IciciBankCompanyAccount'
        return AccountManager::IciciBankAccount::IciciBankCompanyAccountAdapter.new(account, payment)
      when 'CashOnHand'
        return AccountManager::CashOnHand::CashOnHandAdapter.new(account, payment)
      when 'ItzCashCompanyAccount'
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(account, payment)
      when 'BankAccount'
        op = AccountManager::BankAccount::BankAccountAdapter.new(account, payment)
        return op.bank_account_adapter
      when 'VendorPaymentWallet'
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(account, payment)
      when 'UserPocket'
        op = AccountManager::UserPockets::UserPocketsAdapter.new(account, payment)
        return op.pockets_adapter
      when 'UtilityBillsAccount'
        return AccountManager::BillingAccount::UtilityBillsAccountAdapter.new(account, payment)
      when 'BbpsBiller'
        return AccountManager::BbpsBiller::BbpsPaymentsAdapter.new(account, payment)
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end

end