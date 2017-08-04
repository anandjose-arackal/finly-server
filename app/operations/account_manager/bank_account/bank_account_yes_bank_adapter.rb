# this adapter can handle general credits for a bank account
# can belong to either a user, or a vendor.
# Yes Bank in the name suggests that the credit to this account will happen from
# the Yes Bank current account

class AccountManager::BankAccount::BankAccountYesBankAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :bank_account

  def account_class
    BankAccount
  end

  def credit(payment, transfer_type)
    # this will be done by creating the respective payment request for the bank account
    transfer_request = create_transfer_request(payment, transfer_type)
    op = YesBank::Transfer::BankTransfer.(transfer_request)
    if op.success?
      # logic for setting whether a particular payment was successful or is processing
      if op.transfer_request.transaction_status == "COMPLETED"
        payment.update(payment_status_id: PaymentStatus.id_for(:completed))
      elsif op.transfer_request.transaction_status == "SENT_TO_BENEFICIARY"
        payment.update(payment_status_id: PaymentStatus.id_for(:processing))
      elsif op.transfer_request.transaction_status.nil?
        # i.e. there was an error processing the transaction
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        error_message = op.transfer_request.bank_error_message || "Payment could not be processed at this time"
        payment.system_messages.build(content: error_message,
                                      system_message_type_id: SystemMessageType.id_for(:error)).save
        return false
      end
    else
      # i.e. there was an error processing the transaction
      payment.update(payment_status_id: PaymentStatus.id_for(:failed))
      error_message = op.transfer_request.bank_error_message || "Payment could not be processed at this time"
      payment.system_messages.build(content: error_message,
                                    system_message_type_id: SystemMessageType.id_for(:error)).save
      return false
    end
  end

  def debit(payment)
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

  def blocked_amount_for_payments

  end

  def create_transfer_request(payment, transfer_type)
    tr = TransferRequest.(bank_account.name, bank_account.account_number, bank_account.ifsc, payment.amount_value, transfer_type)
  end

end