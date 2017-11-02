class AccountManager::CashOnHand::CashOnHandAdapter < AccountManager::BaseAdapter

  def account_class
    CashOnHand
  end

  def name
    ["Cash On Hand", "CashOnHand"]
  end

  def credit(payment, options)
    success = false
    opening_balance = balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value += payment.amount_value
      success = balance_amount.save
    end
    closing_balance = balance
    if success
      store_transaction payment, :credit, :success, opening_balance, closing_balance, account.user.company_id
      return true
    end
    self.errors = account.errors.full_messages
    store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.user.company_id, error: self.errors
    false
  end

  def debit(payment, options)
    success = false
    opening_balance = balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value -= payment.amount_value
      success = balance_amount.save
    end
    closing_balance = balance
    if success
      store_transaction payment, :debit, :success, opening_balance, closing_balance, account.user.company_id
      return true
    end
    self.errors = account.errors.full_messages
    store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.user.company_id, error: self.errors
    false
  end

  def balance
    balance = self.account.balance_value
    expenses_against_coh_total = self.account.user.expenses.unverified.spent_from_cash_on_hand.joins_amount.sum(:value)
    (balance - expenses_against_coh_total)
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

