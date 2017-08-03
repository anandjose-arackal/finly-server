class AccountManager::Cards::CardAdapter < AccountManager::BaseAdapter

  def account_class
    Card
  end

  def credit(payment)
    # operation that credits a particular card
    op = ItzCash::Credit.(account.user, {card: account, amount: payment.amount_value})
    unless op.success?
      self.errors = op.messages[:error]
      return false
    end
    true
  end

  def debit(payment)
    # operation that debits a particular card
    op = ItzCash::Debit.(account.user, {card: account, amount: payment.amount_value})
    unless op.success?
      self.errors = op.messages[:error]
      return false
    end
    true
  end

  def balance
    op = ItzCash::AccountDetails.(account.user, card: account)
    balance = op.balance
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