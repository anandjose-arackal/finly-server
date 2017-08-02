class AccountManager::Wallet::WalletAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :wallet

  def initialize(source_id)
    init(source_id)
  end

  def init(source_id)
    self.wallet = UserWallet.find_by(id: source_id)
    self.errors = []
  end

  def name
    "Finly Money"
  end

  def credit(payment)
    # credit a particular wallet with the respective amount
    unless self.wallet.add_funds(payment.amount_value)
      self.errors = wallet.errors.full_messages
      return false
    end
    true
  end

  def debit(payment)
    # credit a particular wallet with the respective amount
    unless self.wallet.subtract_funds(payment.amount_value)
      self.errors = wallet.errors.full_messages
      return false
    end
    true
  end

  def balance
    self.wallet.balance_value
  end

  def creditable_accounts
    [Card, "Card", UserWallet, "UserWallet", ItzCashCompanyAccount, "ItzCashCompanyAccount"]
  end

  def debitable_accounts
    [Card, "Card", UserWallet, "UserWallet", ItzCashCompanyAccount, "ItzCashCompanyAccount"]
  end

  def eligibility(amount)
    # checks if the particular wallet can be credited with so and so amount
    true
  end
end