class AccountManager::BankAccount::BankAccountAdapter < AccountManager::BaseAdapter

  def initialize(account = nil)
    super(account)
    case self.account.company.feature_subscription.bank_service_provider.upcase
      when "YESBANK"
        return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
      when "ICICI"
        return AccountManager::BankAccount::BankAccountIciciBankAdapter.new(self.account)
      else
        # temporarily setting the bank account as YesBank for now. Will have to see how to handle this case later
        return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
    end
  end
end