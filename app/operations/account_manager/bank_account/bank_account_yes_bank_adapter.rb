# this adapter can handle general credits for a bank account
# can belong to either a user, or a vendor.
# Yes Bank in the name suggests that the credit to this account will happen from
# the Yes Bank current account

class AccountManager::BankAccount::BankAccountYesBankAdapter < AccountManager::BaseAdapter

  PROCESSING_TRANSACTION_STATUSES = ["SENT_TO_BENEFICIARY", "IN_PROCESS", "SCHEDULED_FOR_NEXT_WORKDAY"]
  FAILED_TRANSACTION_STATUSES = ["FAILED", "RETURNED_FROM_BENEFICIARY"]
  SUCCESSFUL_TRANSACTION_STATUSES = ["COMPLETED"]

  attr_accessor :errors, :company

  def account_class
    BankAccount
  end

  def credit(payment, options = {})
    super
    transfer_type = options[:bank_transfer_type]
    # now based on whether a respective payment has a failed bank transaction or not, decide to use the reference number
    if payment.reference_resource&.retriable?
      reference_number = payment.reference_resource.unique_request_number
    else
      reference_number = nil
    end
    transfer_request = create_transfer_request(payment, transfer_type, reference_number)
    op = YesBankApi::Transfer::BankTransfer.({
        transfer_request: transfer_request,
        payment: payment
    })
    # bank_transaction = op.bank_transaction
    # todo - temporary, for testing
    bank_transaction = create_bank_transaction(payment, transfer_request)
    if op.success?
      if bank_transaction.completed?
        payment.update(payment_status_id: PaymentStatus.id_for(:completed))
        store_transaction payment, :credit, :success, nil, nil, payment.initiating_user&.company_id
      elsif bank_transaction.processing?
        payment.update(payment_status_id: PaymentStatus.id_for(:processing))
        create_system_message_for_processing(payment)
        store_transaction payment, :credit, :processing, nil, nil, payment.initiating_user&.company_id
      end
    else
      # the difference between this and a failure is that the money is not debited back to the account till we're sure
      if bank_transaction.possible_failure?
        payment.update(payment_status_id: PaymentStatus.id_for(:possible_failure))
        create_system_message_for_processing(payment)
        store_transaction payment, :credit, :processing, nil, nil, payment.initiating_user&.company_id
      elsif bank_transaction.failed?
        # i.e. there was an error processing the transaction
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        error_message = op.transfer_request.bank_error_message || op.messages[:error] || "Payment could not be processed at this time"
        store_transaction payment, :credit, :failure, nil, nil, payment.initiating_user&.company_id, {error: self.errors}
        self.errors << error_message
        return false
      end
    end

    #   # logic for setting whether a particular payment was successful or is processing
    #   if SUCCESSFUL_TRANSACTION_STATUSES.include?(op.transfer_request.transaction_result)
    #     payment.update(payment_status_id: PaymentStatus.id_for(:completed))
    #     # create_bank_transaction(payment, op.transfer_request)
    #     store_transaction payment, :credit, :success, nil, nil, payment.initiating_user&.company_id
    #   elsif PROCESSING_TRANSACTION_STATUSES.include?(op.transfer_request.transaction_result)
    #     payment.update(payment_status_id: PaymentStatus.id_for(:processing))
    #     create_system_message_for_processing(payment)
    #     # create_bank_transaction(payment, op.transfer_request)
    #     store_transaction payment, :credit, :processing, nil, nil, payment.initiating_user&.company_id
    #   elsif op.transfer_request.transaction_result.blank?
    #     # i.e. there was an error processing the transaction
    #     payment.update(payment_status_id: PaymentStatus.id_for(:failed))
    #     error_message = op.transfer_request.bank_error_message || "Payment could not be processed at this time"
    #     # create_bank_transaction(payment, op.transfer_request)
    #     store_transaction payment, :credit, :failure, nil, nil, payment.initiating_user&.company_id, {error: self.errors}
    #     self.errors << error_message
    #     return false
    #   end
    # else
    #   # i.e. there was an error processing the transaction - either a 401, or 404, or 500
    #   payment.update(payment_status_id: PaymentStatus.id_for(:failed))
    #   self.errors = op.transfer_request.bank_error_message || op.messages[:error] || 'Payment could not be processed at this time'
    #
    #   store_transaction payment, :credit, :failure, nil, nil, payment.initiating_user&.company_id, {error: self.errors}
    #   return false
    # end
    true
  end

  def debit(payment, options = {})
    super
    # nothing to do here ¯\_(ツ)_/¯
  end

  def balance(options = {})
    # doesn't make sense here because it's outside finly
    # nothing to do here ¯\_(ツ)_/¯
  end

  def creditable_accounts
    # none as this account cannot be credited through Finly (only external)
    [YesBankCompanyAccount, VendorPaymentWallet]
  end

  def debitable_accounts
    []
  end

  def on_completion(options)
    payment = options[:payment]
    if payment.completed?
      op = Event::EBankPaymentRequest::EPayment::CreditConfirm.(payment.initiating_user, payment: payment)
    end
  end

  private

  def create_bank_transaction(payment, transfer_request)
    self.company = account.account_owner.company
    case payment.payment_status_id
      when PaymentStatus.id_for(:completed)
        transfer_status_id = BankTransferStatus.id_for(:completed)
      when PaymentStatus.id_for(:processing)
        transfer_status_id = BankTransferStatus.id_for(:processing)
      when PaymentStatus.id_for(:processing)
        transfer_status_id = BankTransferStatus.id_for(:failed)
      else
        transfer_status_id = BankTransferStatus.id_for(:failed)
    end
    bank_transaction = company.bank_transactions.create(unique_request_number: transfer_request.unique_reference_number,
                                         transfer_type: transfer_request.transfer_type,
                                         bank_reference_number: transfer_request.bank_reference_number,
                                         beneficiary_bank_account: self.account,
                                         transfer_status_id: transfer_status_id,
                                         bank_response: transfer_request.transaction_result,
                                         amount_attributes: {
                                             value: payment.amount_value,
                                             currency_id: Currency.first.id
                                         })
    payment.update(reference_resource: bank_transaction)
    bank_transaction
  end

  def create_system_message_for_processing(payment)
    payment.system_messages.destroy_all
    payment.system_messages.create(system_message_type_id: SystemMessageType.id_for(:info),
                                  content: "Payment processed. Awaiting credit confirmation")
  end

  def create_transfer_request(payment, transfer_type, reference_number)
    tr = TransferRequest.(account.name, account.account_number, account.ifsc, payment.amount_value, reference_number, transfer_type)
  end

end