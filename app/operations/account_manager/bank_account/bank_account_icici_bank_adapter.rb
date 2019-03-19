# this adapter will handle all transactions that hit the ICICI bank server and accordingly
# update a particular payment status

class AccountManager::BankAccount::BankAccountIciciBankAdapter < AccountManager::BankAccount::BankAccountAdapter

  attr_accessor :errors, :company

  def account_class
    BankAccount
  end

  # this method will only initiate a payment in the net bank portal of ICICI, which will then need to be approved
  # Once approved, the transaction will be executed and the UTR will be sent back to us using a callback request
  def credit(payment, options = {})
    super
    transfer_type = options[:bank_transfer_type]
    # now based on whether a respective payment has a failed bank transaction or not, decide to use the reference number

    bank_transaction = payment.reference_resource

    if bank_transaction.present? && (bank_transaction.completed? || bank_transaction.processing? || bank_transaction.possible_failure?)
      # payment cannot be processed in this case
      return false
    elsif bank_transaction&.retriable? || bank_transaction&.open?
      reference_number = bank_transaction.unique_request_number
    else
      # i.e. it's a whole new payment being initiated for the first time
      reference_number = nil
    end

    transfer_request = create_transfer_request(payment, transfer_type, reference_number)

    # If the payment doesn't already have a bank transaction, create one before the API call is initiated
    if payment.reference_resource.blank? && payment.in_progress?
      bank_transaction = create_bank_transaction(payment, transfer_request)
    elsif payment.in_progress?
      bank_transaction = payment.reference_resource
    end


    unless bank_transaction
      payment.system_messages.build(
          content: "Payment cannot be processed at this time",
          system_message_type_id: SystemMessageType.id_for(:error).save
      )
      return false
    end

    op = IciciBankApi::TransactionInitiate.(
      transfer_request: transfer_request,
      payment: payment
    )


    # bank_transaction = op.bank_transaction
    bank_transaction = op.bank_transaction
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
        if TEMPORARY_ERRORS_FROM_BANK.include?(op.transfer_request.bank_error_message)
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
    [IciciBankCompanyAccount, VendorPaymentWallet]
  end

  def debitable_accounts
    []
  end

  def on_completion

  end

  def on_failure

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
    bank_transaction = company.icici_bank_transactions.create(unique_request_number: transfer_request.generate_unique_reference,
                                                        txn_type: transfer_request.transfer_type,
                                                        receiving_account: self.account,
                                                        transfer_status_id: transfer_status_id,
                                                        bank_response: transfer_request.transaction_result,
                                                        remarks: self.payment.note,
                                                        customer_induced: "N",

                                                        amount_attributes: {
                                                            value: payment.amount_value,
                                                            currency_id: Currency.first.id
                                                        })
    payment.with_lock do
      if payment.reference_resource.present?
        return false
      end
      unless payment.update(reference_resource: bank_transaction)
        Event::EAlert::Create.(nil, title: 'Payment did not update with a new bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not update. Details: #{self.payment.errors.full_messages}", subject: 'Payment did not update with a new bank transaction')
      end
    end
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
    tr = IciciBankTransferRequest.(account.name, account.account_number, account.ifsc, payment.amount_value, transfer_type, reference_number, account.company_id)
  end
end
