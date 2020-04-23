class BankTransfer::PaymentRequest::Review::MarkAsCredited < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :view_role, :bank_payment_requests

  def pre_validate
    super
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate the transfer'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    ids = params[:id] || params[:ids] || params[:bank_payment_request_ids] || params[:bank_payment_request_id]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    # self.bank_payment_request = BankPaymentRequest.find_by(id: id)
    self.view_role = UserRole.id_for(params[:view].to_sym)
  end

  def validate
    if self.bank_payment_requests.blank? || self.bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
      return
    end
    bank_payment_requests.each do |payment_request|
      # unless payment_request.approved?
      #   add_message :error, "Payment Order: #{payment_request.name} cannot be marked as Credited as it is #{payment_request.status.name.humanize}"
      # end
      # Allow to mark as credited in open and processing state too
      if payment_request.open? || payment_request.retracted? || payment_request.rejected? || payment_request.credited?
        add_message :error, "Payment Order: #{payment_request.name} cannot be marked as Credited as it is #{payment_request.status.name.humanize}"
      end

      case payment_request.payments.first.class.name
      when 'Invoice'
        payments = payment_request.payments.joins(:invoice).where(invoices: {invoice_status_id: InwardInvoiceStatus.id_for(:voided)})
        if payments.present?
          add_message :error, "Payments with IDs #{payments.pluck(:id).join(", ")} have invoices which are voided. Please remove them before marking the Ticket as credited."
          return
        end
      end
    end
    return if has_errors?
  end

  def process
    self.bank_payment_requests.each do |payment_request|

      parameters = {
        document: payment_request,
        aasm_event: 'mark_as_credited',
      }

      op = WorkflowManager::Base.(user, parameters)

      if op.success?


      # self.workflow_output = op.workflow_output


      # if payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
        # mark the respective payment order and the associated payments as credited
        payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
        payment_request.payment_order.payments.each do |payment|
          payment.update(payment_status_id: PaymentStatus.id_for(:completed))
          update_agreement_beneficiary(payment)
          update_agreement_security_deposit(payment)
        end
        # create the trail for the same
        # payment_request.bank_payment_request_trails.create action_user: user,
        #                                                   action_user_role_id: self.view_role,
        #                                                   action_id: BankPaymentRequestTrailAction.id_for(:mark_as_credited),
        #                                                   modified_user_id: nil,
        #                                                   modified_user_role_id: nil
        # payment_request.trails.create action_user: user,
        #                               action_user_role_id: self.view_role,
        #                               action_id: TrailAction.id_for(:mark_as_credited)

        # if the payment has an associated invoice, update the status of the invoice
        payments = payment_request.payment_order.payments
        payments.each do |payment|
          invoice = payment.invoice
          if invoice.present?
            invoice.update_invoice_status
          end
        end
      else
        add_message :error, op.messages[:error]
      end
    end
  end

  def post_process
    add_message :success, "Payment request marked as credited"

    # generate comments for marking these payment requests as credited
    self.bank_payment_requests.each do |payment_request|
      new_amount = payment_request.payment_order.payments.completed.joins(:amount).sum(:value)
      payment_request.payment_order.assign_attributes({amount_processed_attributes: {value: new_amount, currency_id: 1}})
      payment_request.comments.new user_id: user.id,
                                     action_id: BankPaymentRequestCommentAction.id_for(:mark_as_credited)
      payment_request.save

      Event::EBankPaymentRequest::Credit.(user, bank_payment_request: payment_request)

    end

    # Sending email to original document initiators about payments against it
    # payments = ::Payment.where(payment_order_id: bank_payment_requests.pluck(:payment_order_id)).where.not(purchase_order_id: nil)
    payments = ::Payment.where(payment_order_id: bank_payment_requests.pluck(:payment_order_id))
    payments.each do |payment|
      # notify vendor that they got the money they deserved
      Event::EBankPaymentRequest::NotifyVendor.(user, payment: payment)

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
        document_owner = user
        Event::EBankPaymentRequest::Credit.(document_owner, {payment: payment})
      end
    end
  end

  def update_agreement_beneficiary(payment)
    # beneficiary_payment = user.company.beneficiary_payments.find_by_id(payment.beneficiary_payment_id) rescue nil
    # if beneficiary_payment.present?
    #   payment_agreement = payment.beneficiary_payment.payment_agreement rescue nil
    #   if payment_agreement.present?
    #     beneficiary_payment.update(status_id: BeneficiaryPaymentStatus.id_for(:closed))
    #   end
    # end
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