class AccountManager::Company::YesBankCompanyBalanceAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company

  def initialize(source_id)
    # here source will be a company
    init(source_id)
  end

  def init(source_id)
    self.company = Company.find_by(id: source_id)
  end

  def credit(amount)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def debit(amount)
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def balance
    # can either be an operation or a specific call with
    # a model call
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    []
  end

  def debitable_accounts
    [VendorAccount, "VendorAccount"]
  end

  private

  def blocked_amount_for_payments

  end
end