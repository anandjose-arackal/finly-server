class AccountManager::Cards::CardAdapter < AccountManager::BaseAdapter

  def account_class
    Card
  end

  def credit(payment, options)
    super
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
    true
  end

  def debit(payment, options)
    super
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