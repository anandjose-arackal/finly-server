class AccountManager::YesBankAccount::YesBankCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :yes_bank_account

  def account_class
    YesBankCompanyAccount
  end

  def credit(payment, options = {})
    # this will add money to this company's balance
    opening_balance = balance
    if self.account.balance.update(value: opening_balance + payment.amount_value)
      closing_balance = balance
      store_transaction payment, :credit, :success, opening_balance, closing_balance, nil, account.user.company_id
      return true
    end
    self.errors = self.account.errors.full_messages
    closing_balance = balance
    store_transaction payment, :credit, :failure, opening_balance, closing_balance, nil, account.user.company_id, error: self.errors
    false
  end

  def debit(payment, options = {})
    # nothing to do here ¯\_(ツ)_/¯
    opening_balance = balance
    if self.account.balance.update(value: opening_balance - payment.amount_value)
      closing_balance = balance
      store_transaction payment, :debit, :success, opening_balance, closing_balance, nil, account.user.company_id
      return true
    end
    closing_balance = balance
    store_transaction payment, :debit, :failure, opening_balance, closing_balance, nil, account.user.company_id, error: self.errors
    false
  end

  def balance
    # can either be an operation or a specific call with
    # a model call
    balance = self.account.balance_value
    blocked_amount_for_payments = account.blocked_amount_for_pending_payments
    return (balance - blocked_amount_for_payments)
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [nil, 'OutsideFinly']
  end

  def debitable_accounts
    [BankAccount]
  end

  private

  def blocked_amount_for_payments

  end
end
