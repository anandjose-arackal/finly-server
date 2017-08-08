class AccountManager::OutsideFinly::OutsideFinlyAdapter < AccountManager::BaseAdapter

  # overriding initialize because this is a special case
  def initialize
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything
    self.errors = []

  end

  def account_class
    nil
  end

  def name
    # NilClass because the receiving account will be nil
    "Outside Finly"
  end

  def credit(payment, options)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def debit(payment, options)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def balance
    # no such thing as balance for this, so returning an insanely high number
    # so that balance checks pass
    return 999999999999999999
  end

  def eligibility(payment)
    true
  end

  def creditable_accounts
    # i.e. we cna credit to the user's cash on hand or process a reimbursement
    # outside of Finly
    [nil, CashOnHand]
  end

  def debitable_accounts
    # i.e. cash on hand can be deducted against this
    [CashOnHand, nil, YesBankCompanyAccount]
  end

end
