class AccountManager::VendorPaymentWallet::VendorPaymentWalletAdapter < AccountManager::BaseAdapter

  def account_class
    VendorPaymentWallet
  end

  def name
    ["Finly Credits", "VendorPaymentWallet"]
  end

  def credit(payment, options)
    super
    # credit a particular wallet with the respective amount
    unless self.account.add_funds(payment.amount_value)
      self.errors = account.errors.full_messages
      return false
    end
    true
  end

  def debit(payment, options)
    super
    # credit a particular wallet with the respective amount
    unless self.account.subtract_funds(payment.amount_value)
      self.errors = account.errors.full_messages
      return false
    end
    true
  end

  def balance
    self.account.balance_value
  end

  def creditable_accounts
    [BankAccount, VendorPaymentWallet, YesBankCompanyAccount]
  end

  def debitable_accounts
    [BankAccount, VendorPaymentWallet, YesBankCompanyAccount]
  end

  def eligibility(amount)
    # checks if the particular wallet can be credited with so and so amount
    true
  end
end