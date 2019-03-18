class AccountManager::CreditCardPockets::CreditCardPocketsAdapter < AccountManager::UserPockets::UserPocketsAdapter

  def account_class
    UserPocket
  end

  def name

  end

  # no such thing as credit here because the pool of money is not tracked in Finly
  def credit(payment, options = {})
    true
  end

  # no such thing as debit here because the pool of money is not tracked in Finly
  def debit(payment, options = {})
    true
  end

  # returning an insanely large number as balance because credit amount is not known and this validation should always pass
  def balance(options = {})
    if options[:display_balance]
      return nil
    else
      return 9999999999999999999999
    end
  end

  # returning an insanely large number as balance because credit amount is not known and this validation should always pass
  def database_balance
    9999999999999999999999
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

  def accept_va_transaction?
    false
  end

end