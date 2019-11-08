class BbpsAccountsAdapter < AccountManager::BaseAdapter


  # nothing to do here ¯\_(ツ)_/¯
  def debit(payment, options = {})
    return true
  end

  # this method will consume YesBank's APIs so that they can fulfill our
  # BBPS billers. Have to understand the adapters to implement this
  def credit(payment, options = {})

  end

  # balance doesn't make sense here as there is no such thing defined for this particular account
  def balance

  end


end