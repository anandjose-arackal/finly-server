require 'resque'
class AccountManager::YesBankAccount::YesBankCompanyAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :yes_bank_account, :company

  def account_class
    YesBankCompanyAccount
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

  def balance(options = {})
    # can either be an operation or a specific call with
    # a model call
    self.company = self.account.company
    # jugaad here to enable transferring to the current account for Rapido - if the viewing application is Finly Collect, the pool balance is always shown (even if the company has their current account connected)
    if (self.company.yes_bank_account_enabled? && !self.company.current_account_connected?) || ["fc", :fc].include?(RequestStore.store[:current_app])
      payment_order = options[:payment_order]
      balance = self.account.balance_value
      blocked_amount_for_payments = account.blocked_amount_for_pending_payments(payment_order&.id)
      return (balance - blocked_amount_for_payments)
    elsif (self.company.vendor_payments_enabled? && self.company.current_account_connected?) || (self.company.bank_reimbursement_enabled? && self.company.current_account_connected?)
      return 99999999999999999 if options[:payment_process]

      handle = self.object_id
      YesBankBalanceProvider.perform_async(handle, self.company.id)
      timeout = 30
      now = Time.now
      while (Time.now - now) < timeout
        result = Resque.reserve(handle)
        next if result.blank?

        args = result.args.first
        success = args&.dig('success')
        message = args&.dig('message')
        return 0 unless success

        balance = args['balance']
        balance = balance if balance.class.name == String.name
        payment_order = options[:payment_order]
        blocked_amount_for_payments = account.blocked_amount_for_pending_payments(payment_order&.id)
        return (balance.to_f - blocked_amount_for_payments.to_f)
      end
      return 0
    end
  end

  def database_balance
    self.account.balance_value
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

  def on_va_transaction(payment, options = {})
    credit(payment, options)
  end

  private

  def blocked_amount_for_payments

  end

end
