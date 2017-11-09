class AccountManager::CashOnHand::CashOnHandAdapter < AccountManager::BaseAdapter

  def account_class
    CashOnHand
  end

  def name
    ["Cash On Hand", "CashOnHand"]
  end

  def credit(payment, options)
    opening_balance = database_balance
    if self.account.credit_funds(payment.amount_value)
      closing_balance = database_balance
      store_transaction payment, :credit, :success, opening_balance, closing_balance, account.user.company_id
      return true
    end
    self.errors = account.errors.full_messages
    closing_balance = database_balance
    store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.user.company_id, error: self.errors
    false
  end

  def debit(payment, options)
    opening_balance = database_balance
    if self.account.debit_funds(payment.amount_value)
      closing_balance = database_balance
      store_transaction payment, :debit, :success, opening_balance, closing_balance, account.user.company_id
      return true
    end
    self.errors = account.errors.full_messages
    closing_balance = database_balance
    store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.user.company_id, error: self.errors
    false
  end

  def balance(options = {})
    balance = self.account.balance_value
    expenses_against_coh_total = self.account.user.expenses.unverified.spent_from_cash_on_hand.joins_amount.sum(:value)
    (balance - expenses_against_coh_total)
  end

  def database_balance
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

