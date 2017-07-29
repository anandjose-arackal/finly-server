class AccountManager::CashOnHand::CashOnHandAdapter < AccountManager::BaseAdapter

  def initialize(source_id)
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything
    init(source_id)
  end

  def name
    "Cash On Hand"
  end

  def credit(source_id, amount)

  end

  def debit(source_id, amount)

  end

  def balance(source_id)

  end

  def eligibility(source_id)

  end

  def creditable_accounts
    []
  end

  def debitable_accounts
    []
  end

  def init(source_id)
    # method that retrieves the correct account to transact with

  end

end

