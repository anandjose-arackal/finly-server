class AccountManager::Base < BaseOperation

  protected

  def retrieve_adapter(account_type)
    case account_type.class.to_s
      when 1, Card, "Card"
        # Card, for example
        return AccountManager::Cards::CardAdapter.new(account_type.id)
      when 2, UserWallet, "UserWallet"
        # Wallet for example
        return AccountManager::Wallet::WalletAdapter.new(account_type.id)
      when 3, YesBankCompanyAccount, "YesBankCompanyAccount"
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(account_type.id)
      else
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(account_type.id)
    end
  end
end