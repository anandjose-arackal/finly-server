class AccountManager::IciciBankAccount::IciciBankCompanyAccountAdapter < AccountManager::BaseAdapter

  def account_class
    IciciBankCompanyAccount
  end

  # since we are not maintaining the balance of this account, it shouldn't add
  # anything that is maintained in our databases
  def credit
    self.company = self.account.company
    both_balances = balance
    store_transaction payment, :credit, :success, both_balances, both_balances, account.company_id
    return true
  end

  # since we are not maintaining the balance of this account, it shouldn't add
  # anything that is maintained in our databases
  def debit
    self.company = self.account.company
    both_balances = balance
    store_transaction payment, :debit, :success, both_balances, both_balances, account.company_id
    return true
  end

  def balance
    handle = self.object_id
    IciciBankBalanceProvider.perform_async(handle, self.company.id)
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

  def creditable_accounts
    [nil, 'OutsideFinly', VendorPaymentWallet]
  end

  def debitable_accounts
    [BankAccount, VendorPaymentWallet]
  end

end