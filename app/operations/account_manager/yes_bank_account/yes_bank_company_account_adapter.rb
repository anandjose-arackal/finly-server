class AccountManager::YesBankAccount::YesBankCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :yes_bank_account

  def account_class
    YesBankCompanyAccount
  end

  def credit(payment, options = {})
    # this will add money to this company's balance
    success = false
    opening_balance = balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value += payment.amount_value
      success = balance_amount.save
    end
    closing_balance = balance
    if success
      store_transaction payment, :credit, :success, opening_balance, closing_balance, account.company_id
      return true
    end
    self.errors = self.account.errors.full_messages
    store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.company_id, error: self.errors
    false
  end

  def debit(payment, options = {})
    # this will debit money from the company balance
    success = false
    opening_balance = balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value -= payment.amount_value
      success = balance_amount.save
    end
    closing_balance = balance
    if success
      store_transaction payment, :debit, :success, opening_balance, closing_balance, account.company_id
      return true
    end
    self.errors = self.account.errors.full_messages
    store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.company_id, error: self.errors
    false
  end

  def balance(options = {})
    # can either be an operation or a specific call with
    # a model call
    # payment_order = options[:payment_order]
    # balance = self.account.balance_value
    # blocked_amount_for_payments = account.blocked_amount_for_pending_payments(payment_order&.id)
    # return (balance - blocked_amount_for_payments)
    100000
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [nil, 'OutsideFinly', VendorPaymentWallet, VirtualBankAccount, CashOnHand]
  end

  def debitable_accounts
    [BankAccount, VendorPaymentWallet]
  end

  def accept_va_transaction?
    true
  end

  def on_va_transaction(payment, options={})
    credit(payment, options)
  end

  private

  def blocked_amount_for_payments

  end
end
