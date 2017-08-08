class AccountManager::ItzCashAccount::ItzCashCompanyAccountAdapter < AccountManager::BaseAdapter

  def account_class
    ItzCashCompanyAccount
  end

  def credit(payment, options = {})
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def debit(payment, options = {})
    # nothing to do here ¯\_(ツ)_/¯
    return true
  end

  def balance
    op = ItzCash::VirtualAccountBalance.(account.company)
    if op.success?
      balance = op.wallets.first[:balance] # original balance from ItzCash's servers
      wallets_total = account.total_wallet_balance
      blocked_amount = account.blocked_amount_for_pending_payments
      return (balance - wallets_total - blocked_amount)
    else
      self.errors << "Could not fetch company credits. Try again later"
      return false
    end
  end

  def creditable_accounts
    [Card, UserWallet]
  end

  def debitable_accounts
    [Card, UserWallet]
  end

end