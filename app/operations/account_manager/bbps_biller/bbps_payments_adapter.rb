class AccountManager::BbpsBiller::BbpsPaymentsAdapter < AccountManager::BaseAdapter

  attr_accessor :errors, :company

  def account_class
    BbpsBiller
  end
  # this method will not do anyhing as this account can only be credited
  # nothing to do here ¯\_(ツ)_/¯
  def debit(payment, options = {})
    return true
  end


  # this method will consume YesBank's APIs so that they can fulfill our
  # BBPS billers. Have to understand the adapters to implement this


  # New Flow : Before bill pay, a bill fetch will be done to avoid failures
  # If due is different but amount is same, it will update the bill with new due date and proceed with payment
  # If amount is different while fetching again irrespective of due date, it will mark the payment as failed and stop the flow here
  def credit(payment, options = {})
    # first we determine if the associated payment to this particular transaction is completed or not
    # bill = payment.parent

    bill_fetch_op = Docs::UtilityBills::Subscriptions::Ops::SyncBillPrePayment.(params: {bill_id: payment.parent_id}, current_user: User.first)

    if bill_fetch_op.success?
      bill = bill_fetch_op['result'][:bill]
    else
      self.errors << bill_fetch_op.errors.values
      return false
    end

    # Reload Bill
    bill.reload

    # now the bank transaction will be the first in the list of reference resources
    bank_transaction = payment.reference_resources.first
    if bank_transaction.present? and !bank_transaction.retriable?
      self.errors << "This bill payment cannot be processed at this time"
      return false
    end

    # here we are making sure that all transactions against this payment have failed if it's a retry
    # we are doing this step before creating the new bank transaction - so that the newly created one doesn't cause problems
    op = PaymentProcessorRules::Event.(:ensure_all_previous_transactions_have_failed_before_allowing_retry, {payment: payment, options: options})
    unless op.success?
      self.errors << op.message
      return false
    end

    # checking to ensure that two bank transactions cannot be retried in quick succession - minimum time pf 10 minutes required before each retry
    op = PaymentProcessorRules::Event.(:ensure_successive_payments_are_not_initiated_within_short_timeframe, {payment: payment, options: options})
    unless op.success?
      self.errors << op.message
      return
    end

    bank_transaction = create_bbps_bank_transaction(payment)

    params = {
        amount: bank_transaction.amount_value,
        mobile_number: bank_transaction.customer_mobile,
        bill_date: bank_transaction.bill_date,
        due_date: bank_transaction.due_date,
        bill_number: bank_transaction.bill_number,
        bill_period: bank_transaction.bill_period,
        biller_id: bank_transaction.biller_id,
        quick_pay: bank_transaction.quick_pay,
        order_number: bill.order_number
    }

    params.merge!(customer_params(bill.subscription))

    Bbps::BillPay.(params: params, current_user: payment.initiating_user) do |op|
      op.success do |result|
        puts "Success:Result: #{result}"
        # here we are assuming that the bill gets paid through the BillPay API
        # have to add a check for cases when it's a timeout or any other status other than
        # a 200 OK response
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:processing),
                                bbps_ref_id: result.bbps_ref_id,
                                order_number: bill.order_number)

        # Add log to api response in bill
        api_response = bill.api_response.is_a?(Array) ? bill.api_response : []
        api_response.push(result.as_json&.dig('table').merge({created_at: DateTime.now, api_type: "BillPay"}))

        bill.update(api_response: api_response)

        # clearing old system messages as well
        payment.system_messages.destroy_all
        payment.update(payment_status_id: PaymentStatus.id_for(:processing))

        # add a success system message?
        payment.system_messages.build(content: "The payment has been accepted by BBPS. Awaiting credit confirmation from the service provider",
                                      system_message_type_id: SystemMessageType.id_for(:success)).save
      end
      op.error do |result|
        puts "Error:Result: #{result}"
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:possible_failure))
        payment.update(payment_status_id: PaymentStatus.id_for(:possible_failure))
        result.errors.each do |error|
          add_error_message( payment, error )
          payment.system_messages.build(content: error,
                                        system_message_type_id: SystemMessageType.id_for(:error)).save
        end
        return false
        # any error code
      end
      op.failure do |result|
        puts "Failure:Result: #{result}"
        bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
        payment.update(payment_status_id: PaymentStatus.id_for(:failed))
        result.errors.each do |error|
          add_error_message( payment, error )
          payment.system_messages.build(content: error,
                                        system_message_type_id: SystemMessageType.id_for(:error)).save
        end
        return false
        # 200
      end
    end

    # # now if the above was successful or failed, we shall be updating the status accordingly
    # if op.success?
    #   # i.e. this is a success which will mark the payment as succeeded
    #   if op.status == "Y"
    #     bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:completed), bbps_ref_id: op.bbps_ref_id)
    #     payment.update(payment_status_id: PaymentStatus.id_for(:completed))
    #   elsif payment.response_code != 200
    #     bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:possible_failure))
    #     payment.update(payment_status_id: PaymentStatus.id_for(:possible_failure))
    #   end
    # else
    #   bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:failed))
    #   payment.update(payment_status_id: PaymentStatus.id_for(:failed))
    #   op.errors.each do |error|
    #     payment.system_messages.build(content: error,
    #                                   system_message_type_id: SystemMessageType.id_for(:error)).save
    #   end
    # end
    true
  end

  # balance doesn't make sense here as there is no such thing defined for this particular account,
  # so by default returning zero in case anyone tries to debit this account by mistake
  def balance(options = {})
    return 0
  end

  def creditable_accounts
    [UtilityBillsAccount]
  end

  def debitable_accounts
    []
  end

  private

  def create_bbps_bank_transaction(payment)
    if payment.reference_resources.present?
      return payment.reference_resources.first
    end
    bill = payment.parent
    bank_transaction = payment.company.bbps_yes_bank_transactions.build(
        order_number: retrieve_order_number(payment),
        biller_id: bill.biller.biller_id, # here, parent will be a BbpsBill object, which holds the subscription ID, ID of the BbpsBillerSubscription
        transfer_status_id: BankTransferStatus.id_for(:open),
        bill_date: payment.parent.bill_date,
        bill_period: payment.parent.bill_period,
        due_date: payment.parent.due_date,
        bill_number: payment.parent.bill_number,
        quick_pay: bill.subscription.quick_pay,
        customer_name: bill.subscription.customer_name,
        customer_email: bill.subscription.customer_email,
        customer_mobile: bill.subscription.mobile_number,
        amount_attributes: {
            value: payment.amount_value,
            currency_id: Currency.first.id
        })
    bank_transaction.save

    # now updating the bank transaction and associating it with the payment according to new
    # structure
    unless bank_transaction.update(reference_payment_id: payment.id)
      Event::EAlert::Create.(nil, title: 'New bank transaction did not update with the payment', description: "New bank transaction #{bank_transaction.to_json} did not update with the payment: #{payment.to_json}", subject: 'New bank transaction did not update with the payment inside Payment Executor')
    end

    # additionally also update the payment reference_resource_type to YesBankTransaction
    payment.update(reference_resource_type: bank_transaction.class.name)

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

  # this particular method returns the order number if it's already generated,
  # or generates one on the fly if not present
  def retrieve_order_number(payment)
    bill = payment.parent
    order_number = bill.order_number || generate_order_number
    order_number
  end

  def generate_order_number
    "O#{DateTime.now.strftime("%d%m%y%H%M%S")}#{rand(10000..99999)}"
  end

  def customer_params(subscription)
    parameters = {}

    (1..5).to_a.each do |i|
      key = subscription.send("customer_param_key_#{i}")
      value = subscription.send("customer_param_value_#{i}")
      if key.present? && value.present?
        parameters["customer_param_#{i}"] = {
            key: key,
            value: value
        }
      end
    end
    parameters.symbolize_keys!
  end

  def self.add_error_message payment, error

    if BBPS_ERROR_MESSAGES['BillPayErrorsResponses'][error.to_s].present?
      payment.system_messages.create({
                                         content: BBPS_ERROR_MESSAGES['BillPayErrorsResponses'][error.to_s],
                                         system_message_type_id: SystemMessageType.id_for(:error)
                                     })
    else
      payment.system_messages.create({
                                         content: "Unknown Error Occurred",
                                         system_message_type_id: SystemMessageType.id_for(:error)
                                     })

      message = YAML.load_file("#{Rails.root}/config/new_bbps_errors.yml")
      message[error.to_s] = error.to_s
      File.open("#{Rails.root}/config/new_bbps_errors.yml", 'w') {|file| YAML.dump(message, file)}
    end
  end

end