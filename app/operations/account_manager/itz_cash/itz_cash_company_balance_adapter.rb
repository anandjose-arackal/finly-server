class AccountManager::ItzCash::ItzCashCompanyAccountAdapter < AccountManager::BaseAdapter

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
    op = ItzCash::VirtualAccountBalance.(company)
    balance = op.wallets.first[:balance] # todo - will later subtract pending orders total and then return
  end

  def creditable_accounts
    [Card, "Card", UserWallet, "UserWallet"]
  end

  def debitable_accounts
    [Card, "Card", UserWallet, "UserWallet"]
  end

  private

  def blocked_amount_for_payments

  end
end