class AccountManager::OutsideFinly::OutsideFinlyAdapter < AccountManager::BaseAdapter

  attr_accessor :errors

  def initialize(source = nil, params = nil)
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything
    # nothing to initialize here because there's nothing to do
  end

  def name
    "Outside Finly"
  end

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
    ["CashOnHand", "Reimbursement"]
  end

  def debitable_accounts
    # i.e. cash on hand can be deducted against this
    ["CashOnHand"]
  end

  def init
    # method that retrieves the correct account to debit from

  end

end
