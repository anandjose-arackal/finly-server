class AccountManager::BankAccount::BankAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :bank_account_adapter

  def account_class
    BankAccount
  end

  def initialize(account = nil, payment = nil)
    super(account, payment)
    if payment.blank?
      raise 'Bank account payments require the Payment object as well'
    end

    case payment.company.feature_subscription.bank_service_provider
      when "YES"
        self.bank_account_adapter = AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
      when "ICICI"
        self.bank_account_adapter = AccountManager::BankAccount::BankAccountIciciBankAdapter.new(self.account)
      else
        self.bank_account_adapter = AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
        # return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
    end

    # todo - uncomment this when multi-bank support is implemented
    # # case payment.bank_account_provider_id
    # #   when BankAccountProvider.id_for(:yes_bank)
    # #     return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
    # #   when BankAccountProvider.id_for(:icici_bank)
    # #     return AccountManager::BankAccount::BankAccountIciciBankAdapter.new(self.account)
    # #   when BankAccountProvider.id_for(:kotak_mahindra_bank)
    # #     # todo - temporary
    # #     return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
    # #   else
    # #     raise 'Invalid bank account provider'
    # # end
    #
    # return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
    # # return AccountManager::BankAccount::BankAccountIciciBankAdapter.new(self.account)
    #
    # case payment.company.feature_subscription.bank_service_provider
    #   when "YES"
    #     return AccountManager::BankAccount::BankAccountYesBankAdapter.new(self.account)
    #   when "ICICI"
    #     return AccountManager::BankAccount::BankAccountIciciBankAdapter.new(self.account)
    #   else
    #     raise 'Invalid bank account provider'
    # end
  end
end