class Payments::WalletAdapter < Payments::BaseAdapter

  attr_accessor :wallet

  def init(source_id)
    self.wallet = UserWallet.find_by(id: source_id)
  end

  def credit(source_id, amount)
    # this will credit money to the wallet and debit it from the virtual company
    # balance
    init(source_id)
    wallet.add_funds(amount)
    return true
  end

  def debit(source_id, amount)
    # this will debit money from the wallet
    init(source_id)
    wallet.subtract_funds(amount)
    return true
  end

  def creditable_accounts
    [Card, UserWallet, CompanyBalance]
  end

  def debitable_accounts
    [Card, UserWallet, CompanyBalance]
  end

  def balance(source_id)
    init(source_id)
  end
end