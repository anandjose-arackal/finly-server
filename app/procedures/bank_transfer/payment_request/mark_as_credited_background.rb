class BankTransfer::PaymentRequest::MarkAsCreditedBackground < Transactions::API

  include Transactions::BackgroundWorker

  sidekiq_options queue: :payments_queue

  step :process
  step :post_process

  def process(options, payment_request:, **)
    byebug
    payment_request.payment_order.payments.each do |payment|
      payment.update(payment_status_id: PaymentStatus.id_for(:completed))
      update_agreement_beneficiary(payment)
      update_agreement_security_deposit(payment)
    end
    payments = payment_request.payment_order.payments
    payments.each do |payment|
      invoice = payment.invoice
      if invoice.present?
        invoice.update_invoice_status
      end
    end
    true
  end

  def post_process(options, current_user:, payment_request:, **)
    new_amount = payment_request.payment_order.payments.completed.joins(:amount).sum(:value)
    payment_request.payment_order.assign_attributes({amount_processed_attributes: {value: new_amount, currency_id: ( payment_request&.get_base_currency&.id rescue 1) }})
    payment_request.comments.new user_id: current_user.id,
                                    action_id: BankPaymentRequestCommentAction.id_for(:mark_as_credited)
    payment_request.save

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

