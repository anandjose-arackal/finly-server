# this adapter can handle general credits for a bank account
# can belong to either a user, or a vendor

class AccountManager::BankAccount::BankAccountAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :bank_account

  def account_class
    YesBankCompanyAccount
  end

  def credit(amount, transfer_type)
    # this will be done by creating the respective payment request for the bank account
    transfer_request = create_transfer_request(amount, transfer_type)
    op = YesBank::Transfer::BankTransfer.(transfer_request)
    if op.success?
      return true
      # also add logic for setting payment status based on 'SENT_TO_BENEFICIARY'
      # or 'COMPLETED'
    else
      return false
    end
  end

  def debit(amount)
    # nothing to do here ¯\_(ツ)_/¯

  end

  def balance
    # doesn't make sense here because it's outside finly

  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [YesBankCompanyAccount, "YesBankCompanyAccount"]
  end

  def debitable_accounts
    []
  end

  private

  def blocked_amount_for_payments

  end

  def create_transfer_request(amount, transfer_type)
    tr = TransferRequest.new
    tr.beneficiary_account_number = bank_account.account_number
    tr.ifsc = bank_account.ifsc
    tr.beneficiary_name = bank_account.name
    tr.transfer_type = transfer_type
    tr.company_id = bank_account.account_owner.company_id
    tr.transfer_amount = amount
    tr
  end

end