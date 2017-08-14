class AccountManager::YesBankAccount::YesBankCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :yes_bank_account

  def account_class
    YesBankCompanyAccount
  end

  def credit(payment, options = {})
    # this will add money to this company's balance
    balance = self.account.balance.value
    if self.account.balance.update(value: balance + payment.amount_value)
      return true
    end
    false
  end

  def debit(payment, options = {})
    # nothing to do here ¯\_(ツ)_/¯
    balance = self.account.balance.value
    if self.account.balance.update(value: balance - payment.amount_value)
      return true
    end
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
