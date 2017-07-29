class AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company_account

  def initialize(source_id)
    # here source will be a company
    init(source_id)
  end

  def init(source_id)
    self.company_account = ItzCashCompanyAccount.find_by(id: source_id)
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
    op = ItzCash::VirtualAccountBalance.(company_account.company)
    balance = op.wallets.first[:balance] # original balance from ItzCash's servers
    wallets_total = company_account.total_wallet_balance
    blocked_amount = company_account.blocked_amount_for_pending_payments
    balance - wallets_total - blocked_amount
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