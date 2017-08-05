class AccountManager::CashOnHand::CashOnHandAdapter < AccountManager::BaseAdapter

  def account_class
    CashOnHand
  end

  def credit(payment, options)
    if self.account.credit_funds(payment.amount_value)
      return true
    end
    self.errors = account.errors.full_messages
    false
  end

  def debit(payment, options)
    if self.account.debit_funds(payment.amount_value)
      return true
    end
    self.errors = account.errors.full_messages
    false
  end

  def balance
    self.account.balance_value
  end

  def eligibility(source_id)
    true
  end

  def creditable_accounts
    [nil]
  end

  def debitable_accounts
    [nil]
  end

end

