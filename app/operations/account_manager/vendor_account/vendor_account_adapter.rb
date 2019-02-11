class AccountManager::VendorAccount::VendorAccountAdapter < AccountManager::BaseAdapter

  def account_class
    VendorAccount
  end

  def balance(options = {})
    self.account.balance.value
  end

  def credit(payment, options)
    super
    success = false
    opening_balance = database_balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value += payment.amount_value
      success = balance_amount.save
    end
    closing_balance = database_balance
    # credit a particular vendor account with the respective amount
    unless success
      self.errors = account.errors.full_messages
      store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.vendor.company_id
      return false
    end
    store_transaction payment, :credit, :success, opening_balance, closing_balance, account.vendor.company_id
    true
  end
end