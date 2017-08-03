class AccountManager::OutsideFinly::OutsideFinlyAdapter < AccountManager::BaseAdapter

  def credit(payment)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def debit(payment)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def balance
    # no such thing as balance for this, so returning an insanely high number
    # so that balance checks pass
    return 9999999999999999
  end

  def eligibility(payment)

  end

  def creditable_accounts
    # i.e. we cna credit to the user's cash on hand or process a reimbursement
    # outside of Finly
    [nil, CashOnHand]
  end

  def debitable_accounts
    # i.e. cash on hand can be deducted against this
    [CashOnHand]
  end

  def init
    # method that retrieves the correct account to debit from

  end

end
