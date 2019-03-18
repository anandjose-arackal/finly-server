# this adapter will handle all transactions that hit the ICICI bank server and accordingly
# update a particular payment status

class AccountManager::BankAccount::BankAccountIciciBankAdapter < AccountManager::BankAccount::BankAccountAdapter

  attr_accessor :errors, :company

  def account_class
    BankAccount
  end

  def credit

  end

  def debit

  end

  def balance
    # doesn't make sense here because it's outside finly
    # nothing to do here ¯\_(ツ)_/¯
  end

  def creditable_accounts
    [IciciBankCompanyAccount, VendorPaymentWallet]
  end

  def debitable_accounts
    []
  end

  def on_completion

  end

  def on_failure

  end
end
