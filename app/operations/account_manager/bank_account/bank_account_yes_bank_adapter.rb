# this adapter can handle general credits for a bank account
# can belong to either a user, or a vendor.
# Yes Bank in the name suggests that the credit to this account will happen from
# the Yes Bank current account

class AccountManager::BankAccount::BankAccountYesBankAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company

  def account_class
    BankAccount
  end

  def credit(payment, options = {})
    super
    transfer_type = options[:bank_transfer_type]
    # this will be done by creating the respective payment request for the bank account
    transfer_request = create_transfer_request(payment, transfer_type)
    op = YesBank::Transfer::BankTransfer.(transfer_request)
    if op.success?
      # logic for setting whether a particular payment was successful or is processing
      if op.transfer_request.transaction_result == "COMPLETED"
        payment.update(payment_status_id: PaymentStatus.id_for(:completed))
        create_bank_transaction(payment, op.transfer_request)
      elsif op.transfer_request.transaction_result == "SENT_TO_BENEFICIARY"
        payment.update(payment_status_id: PaymentStatus.id_for(:processing))
        create_bank_transaction(payment, op.transfer_request)
      elsif op.transfer_request.transaction_result.nil?
        # i.e. there was an error processing the transaction
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        error_message = op.transfer_request.bank_error_message || "Payment could not be processed at this time"
        self.errors << error_message
        return false
      end
    else
      # i.e. there was an error processing the transaction
      payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      error_message = op.transfer_request.bank_error_message || "Payment could not be processed at this time"
      self.errors << error_message
      return false
    end
    true
  end

  def debit(payment, options = {})
    super
    # nothing to do here ¯\_(ツ)_/¯
  end

  def balance
    # doesn't make sense here because it's outside finly
    # nothing to do here ¯\_(ツ)_/¯
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [YesBankCompanyAccount, "YesBankCompanyAccount"]
  end

  def debitable_accounts
    []
  end

  private

  def create_bank_transaction(payment, transfer_request)
    self.company = account.company
    case payment.payment_status_id
      when PaymentStatus.id_for(:completed)
        transfer_status_id = BankTransferStatus.id_for(:completed)
      when PaymentStatus.id_for(:processing)
        transfer_status_id = BankTransferStatus.id_for(:processing)
      else
        transfer_status_id = BankTransferStatus.id_for(:failed)
    end
    bt = company.bank_transactions.build(unique_request_number: transfer_request.unique_request_number,
                                         transfer_type: transfer_request.transfer_type,
                                         bank_reference_number: transfer_request.bank_reference_number,
                                         beneficiary_bank_account: self.account,
                                         transfer_status_id: transfer_status_id,
                                         amount_attributes: {
                                             value: payment.amount_value,
                                             currency_id: Currency.first.id
                                         }).save
  end

  def create_transfer_request(payment, transfer_type)
    tr = TransferRequest.(account.name, account.account_number, account.ifsc, payment.amount_value, transfer_type)
  end

end