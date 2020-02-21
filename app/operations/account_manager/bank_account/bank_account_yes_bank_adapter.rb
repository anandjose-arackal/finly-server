# this adapter can handle general credits for a bank account
# can belong to either a user, or a vendor.
# Yes Bank in the name suggests that the credit to this account will happen from
# the Yes Bank current account

class AccountManager::BankAccount::BankAccountYesBankAdapter < AccountManager::BaseAdapter

  PROCESSING_TRANSACTION_STATUSES = ["SENT_TO_BENEFICIARY", "IN_PROCESS", "SCHEDULED_FOR_NEXT_WORKDAY"]
  FAILED_TRANSACTION_STATUSES = ["FAILED", "RETURNED_FROM_BENEFICIARY"]
  if Rails.env.production?
    SUCCESSFUL_TRANSACTION_STATUSES = ["COMPLETED"]
  else
    SUCCESSFUL_TRANSACTION_STATUSES = ["COMPLETED", "SENT_TO_BENEFICIARY"]
  end
  TEMPORARY_ERRORS_FROM_BANK = [
      "Acquiring Bank CBS or node offline",
      "Rejected/Failed at downstream system"
  ]

  attr_accessor :errors, :company

  def account_class
    BankAccount
  end

  def credit(payment, options = {})
    super
    transfer_type = options[:bank_transfer_type] || payment.payment_mode
    # now based on whether a respective payment has a failed bank transaction or not, decide to use the reference number

    bank_transaction = payment.reference_resources.first

    # if the payment is either completed, processing or a possible failure, it cannot be processed
    if bank_transaction.present? && (bank_transaction.completed? || bank_transaction.processing? || bank_transaction.possible_failure?)
      # payment cannot be processed in this case
      return false
    # if the payment has failed, or is in open state, it can be processed with the already generated unique request number
    elsif bank_transaction&.retriable? || bank_transaction&.open?
      reference_number = bank_transaction.unique_request_number
    else
      # i.e. it's a whole new payment being initiated for the first time
      reference_number = nil
    end

    transfer_request = create_transfer_request(payment, transfer_type, reference_number)

    # If the payment doesn't already have a bank transaction, create one before the API call is initiated
    if bank_transaction.blank? && payment.in_progress?
      bank_transaction = create_bank_transaction(payment, transfer_request)
    elsif payment.in_progress?
      bank_transaction = payment.reference_resources.first
    end


    # ensure that a new bank transction is created inside the payments adapter
    # the below case will be reached only if the particular bank transction is not
    # created inside this adapter. Also logging the errors for this particular state
    op = PaymentProcessorRules::Event.(:bank_transaction_must_exist_before_calling_bank_apis, {payment: payment, options: options, bank_transaction: bank_transaction})
    unless op.success?
      self.errors << op.message
      return false
    end

    # adding another rule to ensure that if this is a retry, then all
    # previous bank transactions have failed
    op = PaymentProcessorRules::Event.(:ensure_all_previous_payments_have_failed, {payment: payment, options: options})
    unless op.success?
      self.errors << op.message
      return false
    end

    # unless bank_transaction.present?
    #   payment.system_messages.build(
    #                              content: "Payment cannot be processed at this time - #{bank_transaction.errors.full_messages.to_sentence}",
    #                              system_message_type_id: SystemMessageType.id_for(:error).save
    #   )
    #   return false
    # end

    # checking to ensure that two bank transactions having the same ID can't be present for a single payment
    op = PaymentProcessorRules::Event.(:ensure_successive_payments_are_not_initiated_within_short_timeframe, {payment: payment, options: options})
    unless op.success?
      self.errors << op.message
      return false
    end

    op = YesBankApi::Transfer::BankTransfer.({
        transfer_request: transfer_request,
        payment: payment,
        bank_transaction: bank_transaction
    })

    # bank_transaction = op.bank_transaction
    # transfer_request = op.transfer_request
    #
    #
    # # setting the values of the bank transaction here instead of inside the API Handler
    # # create the bank transaction right here
    # if payment&.reference_resource&.is_a?(YesBankTransaction) || bank_transaction.present?
    #   # just update the bank transaction with the latest details
    #   bank_transaction = bank_transaction || payment.reference_resource
    #   bank_transaction.update(
    #       bank_reference_number: transfer_request.bank_reference_number,
    #       transfer_status_id: op.transfer_status_id,
    #       bank_response: transfer_request.transaction_result,
    #       beneficiary_full_name: transfer_request.beneficiary_full_name
    #   )
    #   payment&.update(retry_count: payment.retry_count.to_f + 1)
    # else
    #   # this is an anomaly, so send email and flag it
    #   Event::EAlert::Create.(nil, title: 'Payment did not have an associated bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not have an associated bank transaction.", subject: 'Payment did not have an associated bank transaction')
    # end


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
        create_system_message_for_possible_failure(payment)
        store_transaction payment, :credit, :processing, nil, nil, payment.initiating_user&.company_id
      elsif bank_transaction.failed?
        # i.e. there was an error processing the transaction
        # Payment with pending transaction will rerun through CronJobs
        if self.account.account_owner.is_a?(Company)
          self.company = self.account.account_owner
        else
          self.company = account.account_owner.company
        end
        if TEMPORARY_ERRORS_FROM_BANK.include?(op.transfer_request.bank_error_message) && self.company.auto_retry_payment_enabled?
          payment.update(payment_status_id: PaymentStatus.id_for(:pending_retry))
        else
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        end
        error_message = op.transfer_request.bank_error_message || op.messages&.dig(:error) || "Payment could not be processed at this time"
        store_transaction payment, :credit, :failure, nil, nil, payment.initiating_user&.company_id, {error: self.errors}
        self.errors << error_message
        return false
      end
    end
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
    [YesBankCompanyAccount, VendorPaymentWallet]
  end

  def debitable_accounts
    []
  end

  def on_completion(options)
    payment = options[:payment]
    if payment&.completed?
      op = Event::EBankPaymentRequest::EPayment::CreditConfirm.(payment.initiating_user, payment: payment)
      # trigger the webhook callback for this particular payment's credit confirmation
      # setting the parameters for the callback method and executing it
      execute_callback(payment)
      # if the payment happens to also have an invoice, update the invoice status accordingly
      if payment.invoice.present?
        payment.invoice.update_invoice_status
      end
    end
  end

  def on_failure(options)
    # trigger the web hook callback for failed payments
    payment = options[:payment]
    if payment&.failed?
      execute_callback(payment)
    end
  end

  private

  def create_bank_transaction(payment, transfer_request)
    if self.account.account_owner.is_a?(Company)
      self.company = self.account.account_owner
    else
      self.company = account.account_owner.company
    end
    case payment.payment_status_id
      when PaymentStatus.id_for(:completed)
        transfer_status_id = BankTransferStatus.id_for(:completed)
      when PaymentStatus.id_for(:processing)
        transfer_status_id = BankTransferStatus.id_for(:processing)
      when PaymentStatus.id_for(:failed)
        transfer_status_id = BankTransferStatus.id_for(:failed)
      else
        transfer_status_id = BankTransferStatus.id_for(:open)
    end
    bank_transaction = company.yes_bank_transactions.create(unique_request_number: transfer_request.unique_request_number,
                                         transfer_type: transfer_request.transfer_type,
                                         bank_reference_number: transfer_request.bank_reference_number,
                                         beneficiary_bank_account: self.account,
                                         transfer_status_id: transfer_status_id,
                                         transfer_mode_id: payment.transfer_mode_id,
                                         bank_response: transfer_request.transaction_result,
                                         amount_attributes: {
                                             value: payment.amount_value,
                                             currency_id: Currency.first.id
                                         })

     # now updating the bank transaction and associating it with the payment according to new
     # structure
     unless bank_transaction.update(reference_payment_id: payment.id)
       Event::EAlert::Create.(nil, title: 'New bank transaction did not update with the payment', description: "New bank transaction #{bank_transaction.to_json} did not update with the payment: #{payment.to_json}", subject: 'New bank transaction did not update with the payment inside Payment Executor')
     end

    # payment.with_lock do
    #   if payment.reference_resource.present?
    #     return false
    #   end
    #   unless payment.update(reference_resource: bank_transaction)
    #     Event::EAlert::Create.(nil, title: 'Payment did not update with a new bank transaction', description: "The payment: #{payment.to_json} inside the API Handler did not update. Details: #{self.payment.errors.full_messages}", subject: 'Payment did not update with a new bank transaction')
    #   end
    # end
    bank_transaction
  end

  def create_system_message_for_processing(payment)
    payment.system_messages.destroy_all
    payment.system_messages.create(system_message_type_id: SystemMessageType.id_for(:info),
                                  content: "Payment processed. Awaiting credit confirmation")
  end

  def create_system_message_for_possible_failure(payment)
    payment.system_messages.destroy_all
    payment.system_messages.create(system_message_type_id: SystemMessageType.id_for(:info),
                                   content: "Possible failure. Awaiting confirmation from bank")
  end

  def create_transfer_request(payment, transfer_type, reference_number)
    tr = YesBankTransferRequest.(account.name, account.account_number, account.ifsc, payment.amount_value, transfer_type, reference_number, account.company_id)
  end

end