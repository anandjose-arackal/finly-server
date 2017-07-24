class AccountManager::Company::CompanyBalanceAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company

  def initialize(source_id)
    # here source will be a company
    init(source_id)
  end

  def init(source_id)
    self.company = Company.find_by(id: source_id)
  end

  def credit(amount)
    return true
  end

  def debit(amount)
    return true
  end

  def balance
    op = ItzCash::VirtualAccountBalance.(company)
    balance = op.wallets.first[:balance] # todo - will later subtract pending orders total and then return
  end

  def creditable_accounts
    [Card, "Card", UserWallet, "UserWallet"]
  end

  def debitable_accounts
    [Card, "Card", UserWallet, "UserWallet"]
  end
end