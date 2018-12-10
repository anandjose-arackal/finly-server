class AccountManager::Base < BackgroundOperation
  sidekiq_options queue: 'payments_queue'

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
        return AccountManager::BankWallet::VendorPaymentWalletAdapter.new(account)
      when 'UserPocket'
        case account.user_pocket_type_id
          when UserPocketType.id_for(:cash)
            return AccountManager::CashPockets::CashPocketsAdapter.new(account)
          when UserPocketType.id_for(:credit_card)
            return AccountManager::CreditCardPockets::CreditCardPocketsAdapter.new(account)
          else
            # do nothing?
        end
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end

end