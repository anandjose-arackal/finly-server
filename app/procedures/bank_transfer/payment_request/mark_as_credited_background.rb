class BankTransfer::PaymentRequest:: MarkAsCreditedBackground < Transactions::API
  
  include Transactions::BackgroundWorker

  sidekiq_options queue: :payments_queue, retry: 0
  sidekiq_options log_level: :warn

  step :update_payments_invoices!
  step :send_credit_mail


  def update_payments_invoices!(options, payment_request:, current_user:, payment_order_status_id:, payment_request_status_id:, controlling_level_id:, **)
    Rails.logger.info "Trying to update payment orders in payment ticket id #{payment_request.id}"
    payment_request.payment_order.payments.update_all(payment_status_id: PaymentStatus.id_for(:completed))
     payment_request.payment_order.payments.each do |payment|
       update_agreement_beneficiary(payment)
       update_agreement_security_deposit(payment)
      case payment.parent_type
      when 'Invoice'
        parent_details = payment.parent
        parent_details.update_invoice_status
      when 'PurchaseOrder'
        parent_details = payment.parent
        parent_details.update(advance_amount_status_id: AdvanceAmountStatus.id_for(:paid))
      end
    end

    Rails.logger.info "Payment Order Invoices updated"

    new_amount = payment_request.payment_order.payments.completed.joins(:amount).sum(:value)
    payment_request.payment_order.assign_attributes({amount_processed_attributes: {value: new_amount, currency_id: ( payment_request&.get_base_currency&.id rescue 1) }})
    payment_request.comments.new user_id: current_user.id,
                                 action_id: BankPaymentRequestCommentAction.id_for(:mark_as_credited)

    Rails.logger.info "Amount calculations done!"

    res = payment_request.save

    if res
      Rails.logger.info "Payment Request Saved successfully"
    end

    Rails.logger.info res
    res
  end


  def send_credit_mail(options, current_user:, payment_request:, **)
    
    Event::EBankPaymentRequest::Credit.(current_user, bank_payment_request: payment_request)

    payments = Payment.where(payment_order_id: payment_request.payment_order_id)
    payments.each do |payment|
      # notify vendor that they got the money they deserved
      Event::EBankPaymentRequest::NotifyVendor.(current_user, payment: payment)

      case payment.parent_type
      when 'Invoice'        
        document_owner = payment.invoice.created_by
        Event::EInvoice::Credit.(document_owner, {payment: payment})
      when 'PurchaseOrder'
        document_owner = payment.purchase_order.user
        Event::EPurchaseOrder::Credit.(document_owner, {payment: payment})
      when 'Beneficiary'
        document_owner = payment.invoice.created_by
        Event::EBankPaymentRequest::Credit.(document_owner, {payment: payment})
      else
        document_owner = current_user
        Event::EBankPaymentRequest::Credit.(document_owner, {payment: payment})
      end
    end
  end

  def update_agreement_beneficiary(payment)
    if payment.parent_type == "BeneficiaryPayment" && payment.parent.payment_agreement_id.present?
      unless payment.parent.status_id == BeneficiaryPaymentStatus.id_for(:paid)
        payment.parent.update(status_id: BeneficiaryPaymentStatus.id_for(:paid))
      end
    end
  end

  def update_agreement_security_deposit(payment)
    if payment.parent_type == "SecurityDeposit" && payment.parent.payment_agreement_id.present?
      unless payment.parent.status_id == SecurityDepositStatus.id_for(:paid)
        payment.parent.update(status_id: SecurityDepositStatus.id_for(:paid))
      end
    end
  end

end
