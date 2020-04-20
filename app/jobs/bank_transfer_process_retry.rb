class BankTransferProcessRetry

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    failed_payments_for_retry = Payment.where(payment_status_id: PaymentStatus.id_for(:pending_retry))
    if failed_payments_for_retry.present?
      failed_payments_for_retry.each do |payment|
        # if this payment has been retried more than 5 times, then stop the retry and mark it as failed
        if payment.pending_retry? && payment.retry_count > 5
          payment.update(payment_status_id: PaymentStatus.id_for(:failed))
          execute_callback(payment)
        end
        if payment.payment_order&.company&.auto_retry_payment_enabled?
          AccountManager::Payments::RetryPaymentBackground.(payment, {})
        end
      end
    end

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

  def self.execute_callback(payment)
    post_params = {
        payment_id: payment.id,
        payment_amount: payment.amount_value,
        note: payment.note,
        status: payment.payment_status&.name,
        receiving_account: {
            receiving_account_type: "BankAccount",
            receiving_account_id: payment.receiving_account&.id,
            receiving_account_number: payment.receiving_account&.account_number,
            receiving_account_ifsc: payment.receiving_account&.ifsc
        },
        bank_reference_number: payment.utr
    }
    if payment.failed?
      post_params[:errors] = payment.system_messages.errors.pluck(:content).to_sentence
    end
    # this particular type of payment will always have an initiating user because it is a vendor payment / reimbursement payment
    company = payment.initiating_user&.company
    op = Webhook::Process.(nil, {company: company, body: post_params, web_hook_event_id: WebHookEvent.id_for('vendor_payments.credit_confirmation')})
    # creating the webhook track based on the response of the particular operation
    if company.web_hooks.present?
      callback_track = CallbackTrack.new(company: company, entity: payment, request: post_params.to_s)
      if op.success?
        callback_track.update(success: true, response: (op.body rescue nil))
      else
        callback_track.update(success: false, response: (op.body rescue nil))
      end
    end
  end
end