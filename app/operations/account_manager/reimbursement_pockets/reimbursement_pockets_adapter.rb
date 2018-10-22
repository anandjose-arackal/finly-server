class AccountManager::ReimbursementPockets::ReimbursementPocketsAdapter < AccountManager::BaseAdapter

  def account_class
    UserPocket
  end

  def name
  end

  def credit(payment, options = {})
    success = false
    opening_balance = database_balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value += payment.amount_value
      success = balance_amount.save
    end
    closing_balance = database_balance
    if success
      store_transaction payment, :credit, :success, opening_balance, closing_balance, account.user.company_id
      return true
    end
    self.errors = account.errors.full_messages
    store_transaction payment, :credit, :failure, opening_balance, closing_balance, account.user.company_id, error: self.errors
    false
  end

  def debit(payment, options = {})
    success = false
    opening_balance = database_balance
    balance_amount = self.account.balance
    balance_amount.with_lock do
      balance_amount.value -= payment.amount_value
      success = balance_amount.save
    end
    closing_balance = database_balance
    if success
      store_transaction payment, :debit, :success, opening_balance, closing_balance, account.user.company_id
      return true
    end
    self.errors = account.errors.full_messages
    store_transaction payment, :debit, :failure, opening_balance, closing_balance, account.user.company_id, error: self.errors
    false
  end

  def balance(options = {})
    balance = self.account.balance_value
    if options[:display_balance]
      pending_reimbursement = 0
      # extracting all expenses which were marked against this particular pocket
      self.account.user.expenses.unverified.with_spent_from_id(self.account.id).include_spent_from_calculation.each do |expense|
        unless expense.date == DateUtils.local_date && expense.amount&.currency_id != expense.spent_from&.base_currency&.id
          pending_reimbursement += 0#app/operations/export_manager/request_handler.rb:76expense.amount.send(expense.spent_from&.base_currency&.country_code&.to_sym).to_f
        end
      end
      # expenses_against_coh_total = self.account.user.expenses.unverified.spent_from_cash_on_hand.blocked_against_cash_on_hand.joins_amount.sum(:value)
      (balance + pending_reimbursement)
    else
      balance
    end
  end

  def database_balance
    self.account.balance_value
  end

  def eligibility(source_id)
    true
  end

  def creditable_accounts
    [nil]
  end

  def debitable_accounts
    [nil]
  end

  def accept_va_transaction?
    false
  end

end