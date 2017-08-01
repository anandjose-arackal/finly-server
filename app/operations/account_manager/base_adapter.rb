class AccountManager::BaseAdapter

  attr_accessor :errors

  def initialize(source = nil, params = nil)
    # source is the source from where the credit / debit is supposed to happen
    # params is general, can be anything

  end

  def name

  end

  def credit(payment)

  end

  def debit(payment)

  end

  def balance(payment)

  end

  def eligibility(payment)

  end

  def creditable_accounts

  end

  def debitable_accounts

  end

  def init
    # method that retrieves the correct account to debit from

  end

end