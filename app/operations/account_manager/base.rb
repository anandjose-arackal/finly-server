class AccountManager::Base < BaseOperation

  def user_model
    [User, AdminUser]
  end

  protected

  def retrieve_adapter(account_type)
    acc_type = account_type&.class&.to_s
    case acc_type
      when 1, Card, "Card"
        return AccountManager::Cards::CardAdapter.new(account_type.id)
      when 2, UserWallet, "UserWallet"
        return AccountManager::Wallet::WalletAdapter.new(account_type.id)
      when 3, YesBankCompanyAccount, "YesBankCompanyAccount"
        return AccountManager::YesBankAccount::YesBankCompanyAccountAdapter.new(account_type.id)
      when 4, "CashOnHand"
        return AccountManager::CashOnHand::CashOnHandAdapter.new(account_type.id)
      when 5, ItzCashCompanyAccount, "ItzCashCompanyAccount"
        return AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(account_type.id)
      else # i.e. the transaction has happened outside Finly
        return AccountManager::OutsideFinly::OutsideFinlyAdapter.new
    end
  end
end