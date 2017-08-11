class AccountManager::Wallet::WalletAdapter < AccountManager::BaseAdapter

  def account_class
    UserWallet
  end

  def name
    ["Finly Money", "UserWallet"]
  end

  def credit(payment, options)
    super
    opening_balance = balance
    # credit a particular wallet with the respective amount
    unless self.account.add_funds(payment.amount_value)
      self.errors = account.errors.full_messages
      closing_balance = balance
      store_transaction payment, :credit, :failure, opening_balance, closing_balance, nil, account.user.company_id, error: self.errors
      return false
    end
    closing_balance = balance
    store_transaction payment, :credit, :success, opening_balance, closing_balance, nil, account.user.company_id
    true
  end

  def debit(payment, options)
    super
    opening_balance = balance
    # debit a particular wallet with the respective amount
    unless self.account.subtract_funds(payment.amount_value)
      self.errors = account.errors.full_messages
      closing_balance = balance
      store_transaction payment, :debit, :failure, opening_balance, closing_balance, nil, account.user.company_id, error: self.errors
      return false
    end
    closing_balance = balance
    store_transaction payment, :debit, :success, opening_balance, closing_balance, nil, account.user.company_id
    true
  end

  def balance
    self.account.balance_value
  end

  def creditable_accounts
    [Card, UserWallet, ItzCashCompanyAccount]
  end

  def debitable_accounts
    [Card, UserWallet, ItzCashCompanyAccount]
  end

  def eligibility(amount)
    # checks if the particular wallet can be credited with so and so amount
    true
  end
end