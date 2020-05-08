class AccountManager::BillingAccount::UtilityBillsAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :utility_bills_account, :company

  def account_class
    UtilityBillsAccount
  end

  def credit(payment, options = {})
    # this will add money to this company's balance
    self.company = self.account.company
    if self.company.current_account_connected? && !["fc", :fc].include?(payment.application)
      both_balances = balance
      store_transaction payment, :credit, :success, both_balances, both_balances, account.company_id
      return true
    else
      success = false
      opening_balance = database_balance
      balance_amount = self.account.balance
      balance_amount.with_lock do
        balance_amount.value += payment.amount_value
        success = balance_amount.save
      end
      closing_balance = database_balance
      if success
        store_transaction payment, :credit, :success, opening_balance, closing_balance, account.company_id
        return true
      end
      self.errors = self.account.errors.full_messages
      store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.company_id, error: self.errors
      false
    end
  end

  def debit(payment, options = {})
    # this will debit money from the company balance
    self.company = self.account.company
    if self.company.current_account_connected? && !["fc", :fc].include?(payment.application)
      both_balances = balance
      store_transaction payment, :debit, :success, both_balances, both_balances, account.company_id
      return true
    else
      success = false
      opening_balance = database_balance
      balance_amount = self.account.balance
      balance_amount.with_lock do
        balance_amount.value -= payment.amount_value
        success = balance_amount.save
      end
      closing_balance = database_balance
      if success
        store_transaction payment, :debit, :success, opening_balance, closing_balance, account.company_id
        return true
      end
      self.errors = self.account.errors.full_messages
      store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.company_id, error: self.errors
      false
    end
  end

  def database_balance
    self.account.balance_value
  end

  def balance(options = {})
    payment_order = options[:payment_order]
    balance = self.account.balance_value
    blocked_amount_for_payments = account.blocked_amount_for_pending_payments(payment_order&.id)
    return (balance - blocked_amount_for_payments)
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [nil, 'OutsideFinly', VirtualBankAccount]
  end

  def debitable_accounts
    # insert account type for BBPS payments, whatever they may be
    [BbpsBiller]
  end

  def accept_va_transaction?
    true
  end

  def on_va_transaction(payment, options = {})
    credit(payment, options)
  end


end