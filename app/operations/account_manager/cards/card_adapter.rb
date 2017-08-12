class AccountManager::Cards::CardAdapter < AccountManager::BaseAdapter

  def account_class
    Card
  end

  def credit(payment, options)
    super
    # Since this function debits ItzCashCompanyAccount, create 2 transactions, one for company account and other for card
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

    # operation that credits a particular card
    opening_balance = balance
    op = ItzCash::Credit.(account.user, {card: account, amount: payment.amount_value})
    unless op.success?
      self.errors = op.messages[:error]
      closing_balance = balance
      store_transaction payment, :credit, :failure, opening_balance, closing_balance, nil, account.user.company_id, op.messages
      return false
    end
    closing_balance = balance
    store_transaction payment, :credit, :success, opening_balance, closing_balance, nil, account.user.company_id

    if company_adapter.present?
      closing_company_balance = company_adapter.balance
      company_adapter.store_transaction payment, :debit, :success, company_balance, closing_company_balance, nil, company_adapter.account.id
    end
    true
  end

  def debit(payment, options)
    super
    # Since this function debits ItzCashCompanyAccount, create 2 transactions, one for company account and other for card
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
    # operation that debits a particular card
    op = ItzCash::Debit.(account.user, {card: account, amount: payment.amount_value})
    unless op.success?
      self.errors = op.messages[:error]
      closing_balance = balance
      store_transaction payment, :debit, :failure, opening_balance, closing_balance, nil, account.user.company_id, op.messages
      return false
    end
    closing_balance = balance
    store_transaction payment, :debit, :success, opening_balance, closing_balance, nil, account.user.company_id

    if company_adapter.present?
      closing_company_balance = company_adapter.balance
      company_adapter.store_transaction payment, :credit, :success, company_balance, closing_company_balance, nil, company_adapter.account.id
    end

    true
  end

  def balance
    op = ItzCash::AccountDetails.(account.user, card: account)
    op.balance
  end

  def creditable_accounts
    [Card, UserWallet, ItzCashCompanyAccount]
  end

  def debitable_accounts
    [Card, UserWallet, ItzCashCompanyAccount]
  end

  def eligibility(payment)
    # checks if the particular card can be credited with so and so amount
    true
  end
end