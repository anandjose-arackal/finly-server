class AccountManager::YesBankAccount::YesBankCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :yes_bank_account

  def initialize(source_id)
    # here source will be a company
    init(source_id)
  end

  def init(source_id)
    self.company = Company.find_by(id: source_id)
  end

  def credit(amount)
    # this will add money to this company's balance
    balance = self.yes_bank_account.balance.value
    if self.yes_bank_account.update(balance: (balance + amount))
      return true
    end
    false
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
    [nil, "OutsideFinly"]
  end

  def debitable_accounts
    [VendorAccount, "VendorAccount"]
  end

  private

  def blocked_amount_for_payments

  end
end