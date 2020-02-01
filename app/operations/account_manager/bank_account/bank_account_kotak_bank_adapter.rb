# this adapter can handle general credits for a bank account
# can belong to either a user, or a vendor.
# Yes Bank in the name suggests that the credit to this account will happen from
# the Yes Bank current account

class AccountManager::BankAccount::BankAccountKotakBankAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company

  def account_class
    BankAccount
  end

  def credit(payment, options = {})
    super
    transfer_type = options[:bank_transfer_type] || payment.payment_mode
    # now based on whether a respective payment has a failed bank transaction or not, decide to use the reference number

    bank_transaction = payment.reference_resources.first

    if bank_transaction.present? && (bank_transaction.completed? || bank_transaction.processing? || bank_transaction.possible_failure?)
      # payment cannot be processed in this case
      return false
    elsif bank_transaction&.retriable? || bank_transaction&.open?
      # reference_number = bank_transaction.unique_reference_number
      # Setting reference number as nil, as Kotak Bank requires new unique number everytime
      reference_number = nil
    else
      # i.e. it's a whole new payment being initiated for the first time
      reference_number = nil
    end

    transfer_request = create_transfer_request(payment, transfer_type, reference_number)

    # If the payment doesn't already have a bank transaction, create one before the API call is initiated
    if bank_transaction&.retriable?
      bank_transaction.update_columns(unique_reference_number: transfer_request.unique_reference_number)
    elsif bank_transaction.blank? && payment.in_progress?
      bank_transaction = create_bank_transaction(payment, transfer_request)
    elsif payment.in_progress?
      bank_transaction = payment.reference_resources.first
    end


    unless bank_transaction
      payment.system_messages.build(
                                 content: "Payment cannot be processed at this time",
                                 system_message_type_id: SystemMessageType.id_for(:error).save
      )
      return false
    end

    # Initiates transaction
    op = KotakBankApi::Transfer.({
        transfer_request: transfer_request,
        payment: payment
    })

    # bank_transaction = op.bank_transaction
    bank_transaction = op.bank_transaction
    if op.success?
      if bank_transaction.completed?
        payment.update(payment_status_id: PaymentStatus.id_for(:initiated))
        store_transaction payment, :credit, :success, nil, nil, payment.initiating_user&.company_id
      else
        # Handle Failed / Possible Failure
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
        error_message = op.transfer_request.transaction_result || op.messages&.dig(:error) || "Payment could not be processed at this time"
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
    # none as this account cannot be credited through Finly (only external)
    [KotakBankCompanyAccount, VendorPaymentWallet]
  end

  def debitable_accounts
    []
  end

  # def on_completion(options)
  #   payment = options[:payment]
  #   if payment&.completed?
  #     op = Event::EBankPaymentRequest::EPayment::CreditConfirm.(payment.initiating_user, payment: payment)
  #     # trigger the webhook callback for this particular payment's credit confirmation
  #     # setting the parameters for the callback method and executing it
  #     execute_callback(payment)
  #     # if the payment happens to also have an invoice, update the invoice status accordingly
  #     if payment.invoice.present?
  #       payment.invoice.update_invoice_status
  #     end
  #   end
  # end
  #
  # def on_failure(options)
  #   # trigger the webhook callback for failed payments
  #   payment = options[:payment]
  #   if payment&.failed?
  #     execute_callback(payment)
  #   end
  # end
  #
  # def execute_callback(payment)
  #   post_params = {
  #       payment_id: payment.id,
  #       payment_amount: payment.amount_value,
  #       note: payment.note,
  #       status: payment.payment_status&.name,
  #       receiving_account: {
  #           receiving_account_type: "BankAccount",
  #           receiving_account_id: payment.receiving_account&.id,
  #           receiving_account_number: payment.receiving_account&.account_number,
  #           receiving_account_ifsc: payment.receiving_account&.ifsc
  #       },
  #       bank_reference_number: payment.reference_resource&.bank_reference_number
  #   }
  #   if payment.failed?
  #     post_params[:errors] = payment.system_messages.errors.pluck(:content).to_sentence
  #   end
  #   # this particular type of payment will always have an initiating user because it is a vendor payment / reimbursement payment
  #   company = payment.initiating_user&.company
  #   op = Webhook::Process.(nil, {company: company, body: post_params, web_hook_event_id: WebHookEvent.id_for('vendor_payments.credit_confirmation')})
  #   if company.web_hooks.present?
  #     callback_track = CallbackTrack.new(company: company, entity: payment, request: post_params.to_s)
  #     if op.success?
  #       callback_track.update(success: true, response: (op.body rescue nil))
  #     else
  #       callback_track.update(success: false, response: (op.body rescue nil))
  #     end
  #   end
  # end

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

    kotak_bank_transaction_params = {
        unique_reference_number: transfer_request.generate_unique_reference,
        transfer_type: transfer_request.transfer_type,
        utr: transfer_request.bank_reference_number,
        beneficiary_account: self.account,
        beneficiary_account_number: self.account.account_number,
        beneficiary_account_ifsc: self.account.ifsc,
        beneficiary_name: self.account.name,
        transfer_status_id: transfer_status_id,
        transfer_mode_id: payment.transfer_mode_id,
        reference_payment_id: payment.id,
        narration: payment.note,
        amount_attributes: {
            value: payment.amount_value,
            currency_id: Currency.first.id
        }
    }
    bank_transaction = company.kotak_bank_transactions.new(kotak_bank_transaction_params)
    bank_transaction.save

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
    #     Event::EAlert::Create.(nil, title: 'Payment did not update with a new bank transaction', description: "The payment: #{self.payment.to_json} inside the API Handler did not update. Details: #{self.payment.errors.full_messages}", subject: 'Payment did not update with a new bank transaction')
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
    # tr = KotakBankTransferRequest.(account.name, account.account_number, account.ifsc, payment.amount_value, transfer_type, reference_number, account.company_id)
    tr = KotakBankTransferRequest.(account.name, account.account_number, account.ifsc, payment.amount_value, transfer_type, reference_number, account.company_id)
  end

end