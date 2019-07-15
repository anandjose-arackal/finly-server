class AccountManager::KotakBankAccount::KotakBankCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :company

  def account_class
    KotakBankCompanyAccount
  end

  # since we are not maintaining the balance of this account, it shouldn't add
  # anything that is maintained in our databases
  def credit(payment, options = {})
    self.company = self.account.company
    both_balances = balance
    store_transaction payment, :credit, :success, both_balances, both_balances, account.company_id
    return true
  end

  # since we are not maintaining the balance of this account, it shouldn't add
  # anything that is maintained in our databases
  def debit(payment, options = {})
    self.company = self.account.company
    both_balances = balance
    store_transaction payment, :debit, :success, both_balances, both_balances, account.company_id
    return true
  end

  def balance(options = {})
    # Balance API is not provided so returning really large balance
    999999999999
  end

  def creditable_accounts
    [nil, 'OutsideFinly', VendorPaymentWallet]
  end

  def debitable_accounts
    [BankAccount, VendorPaymentWallet]
  end

end