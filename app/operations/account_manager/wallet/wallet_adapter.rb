class AccountManager::Wallet::WalletAdapter < AccountManager::BaseAdapter

  def account_class
    UserWallet
  end

  def name
    ['Finly Money', 'UserWallet']
  end

  def credit(payment, options)
    super
    # Since this function debits ItzCashCompanyAccount, create 2 transactions, one for company account and other for wallet
    company_balance = nil
    company_adapter = nil
    if payment.initiating_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.initiating_account)
    end
    if payment.receiving_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.receiving_account)
    end
    if company_adapter.present?
      company_balance = company_adapter.balance
    end

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

    if company_adapter.present?
      closing_company_balance = company_adapter.balance
      company_adapter.store_transaction payment, :debit, :success, company_balance, closing_company_balance, nil, company_adapter.account.company_id
    end
    true
  end

  def debit(payment, options)
    super
    # Since this function debits ItzCashCompanyAccount, create 2 transactions, one for company account and other for wallet
    company_balance = nil
    company_adapter = nil
    if payment.initiating_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.initiating_account)
    end
    if payment.receiving_account.class.name == ItzCashCompanyAccount.name
      company_adapter = AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter.new(payment.receiving_account)
    end
    if company_adapter.present?
      company_balance = company_adapter.balance
    end

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

    if company_adapter.present?
      closing_company_balance = company_adapter.balance
      company_adapter.store_transaction payment, :credit, :success, company_balance, closing_company_balance, nil, company_adapter.account.company_id
    end
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