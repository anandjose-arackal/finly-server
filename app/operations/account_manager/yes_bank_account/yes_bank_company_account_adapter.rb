class AccountManager::YesBankAccount::YesBankCompanyAccountAdapter < AccountManager::BaseAdapter

  def account_class
    YesBankCompanyAccount
  end

  def credit(amount)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def debit(amount)
    # nothing to do here ¯\_(ツ)_/¯

  end

  def balance
    # can either be an operation or a specific call with
    # a model call
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [nil]
  end

  def debitable_accounts
    [BankAccount]
  end

  private

  def blocked_amount_for_payments

  end
end
