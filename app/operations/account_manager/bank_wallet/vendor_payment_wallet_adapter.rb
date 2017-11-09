class AccountManager::BankWallet::VendorPaymentWalletAdapter < AccountManager::BaseAdapter

  def account_class
    VendorPaymentWallet
  end

  def name
    ["Finly Credits", "VendorPaymentWallet"]
  end

  def credit(payment, options)
    super
    opening_balance = balance
    # credit a particular wallet with the respective amount
    unless self.account.add_funds(payment.amount_value)
      self.errors = account.errors.full_messages
      closing_balance = balance
      store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.user.company_id
      return false
    end
    closing_balance = balance
    store_transaction payment, :credit, :success, opening_balance, closing_balance, account.user.company_id
    true
  end

  def debit(payment, options)
    super
    opening_balance = balance
    # debit a particular wallet with the respective amount
    unless self.account.subtract_funds(payment.amount_value)
      self.errors = account.errors.full_messages
      closing_balance = balance
      store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.user.company_id
      return false
    end
    closing_balance = balance
    store_transaction payment, :debit, :success, opening_balance, closing_balance, account.user.company_id
    true
  end

  def balance(options = {})
    payment_order = options[:payment_order]
    balance = self.account.balance_value
    blocked_amount = self.account.blocked_amount_for_pending_payments(payment_order&.id)
    return (balance - blocked_amount)
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