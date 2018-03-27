class AccountManager::BankWallet::VendorPaymentWalletAdapter < AccountManager::BaseAdapter

  def account_class
    VendorPaymentWallet
  end

  def name
    ["Finly Credits", "VendorPaymentWallet"]
  end

  def credit(payment, options)
    super
    success = false
    opening_balance = database_balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value += payment.amount_value
      success = balance_amount.save
    end
    closing_balance = database_balance
    # credit a particular wallet with the respective amount
    unless success
      self.errors = account.errors.full_messages
      store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.user.company_id
      return false
    end
    store_transaction payment, :credit, :success, opening_balance, closing_balance, account.user.company_id
    true
  end

  def debit(payment, options)
    super
    success = false
    opening_balance = database_balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value -= payment.amount_value
      success = balance_amount.save
    end
    closing_balance = database_balance
    # debit a particular wallet with the respective amount
    unless success
      self.errors = account.errors.full_messages
      store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.user.company_id
      return false
    end
    store_transaction payment, :debit, :success, opening_balance, closing_balance, account.user.company_id
    true
  end

  def balance(options = {})
    payment_order = options[:payment_order]
    balance = self.account.balance_value
    blocked_amount = self.account.blocked_amount_for_pending_payments(payment_order&.id)
    return (balance - blocked_amount)
  end

  def database_balance
    self.account.balance_value
  end

  def creditable_accounts
    [nil, 'OutsideFinly', BankAccount, VendorPaymentWallet, YesBankCompanyAccount]
  end

  def debitable_accounts
    [BankAccount, VendorPaymentWallet, YesBankCompanyAccount]
  end

  def eligibility(amount)
    # checks if the particular wallet can be credited with so and so amount
    true
  end

  def accept_va_transaction?
    true
  end

  def on_va_transaction(payment, options={})
    credit(payment, options)
  end

end