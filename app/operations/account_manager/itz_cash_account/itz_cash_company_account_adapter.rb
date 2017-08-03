class AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter < AccountManager::BaseAdapter

  def account_class
    ItzCashCompanyAccount
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
    op = ItzCash::VirtualAccountBalance.(account.company)
    balance = op.wallets.first[:balance] # original balance from ItzCash's servers
    wallets_total = account.total_wallet_balance
    blocked_amount = account.blocked_amount_for_pending_payments
    balance - wallets_total - blocked_amount
  end

  def creditable_accounts
    [Card, UserWallet]
  end

  def debitable_accounts
    [Card, UserWallet]
  end

end