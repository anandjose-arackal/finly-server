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
    ids = params[:id] || params[:bank_payment_request_ids] || params[:bank_payment_request_id]
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
      unless payment_request.approved?
        add_message :error, "Payment Order: #{payment_request.name} cannot be marked as Credited as it is #{payment_request.status.name.humanize}"
      end
    end
    return if has_errors?
  end

  def process
    self.bank_payment_requests.each do |payment_request|
      if payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
        # mark the respective payment order and the associated payments as credited
        payment_request.payment_order.update(payment_order_status_id: PaymentOrderStatus.id_for(:completed))
        payment_request.payment_order.payments.each do |payment|
          payment.update(payment_status_id: PaymentStatus.id_for(:completed))
        end
        # create the trail for the same
        payment_request.bank_payment_request_trails.create action_user: user,
                                                          action_user_role_id: self.view_role,
                                                          action_id: BankPaymentRequestTrailAction.id_for(:mark_as_credited),
                                                          modified_user_id: nil,
                                                          modified_user_role_id: nil
        payment_request.trails.create action_user: user,
                                      action_user_role_id: self.view_role,
                                      action_id: TrailAction.id_for(:mark_as_credited)

        # if the payment has an associated invoice, update the status of the invoice
        payments = payment_request.payment_order.payments
        payments.each do |payment|
          invoice = payment.invoice
          if invoice.present?
            invoice.update_invoice_status
          end
        end
      else
        add_message :error, bank_payment_request.errors.full_messages
      end
    end
  end

  def post_process
    add_message :success, "Payment request marked as credited"

    # generate comments for marking these payment requests as credited
    self.bank_payment_requests.each do |payment_request|
      payment_request.comments.create user_id: user.id,
                                     action_id: BankPaymentRequestCommentAction.id_for(:mark_as_credited)

      Event::EBankPaymentRequest::Credit.(user, bank_payment_request: payment_request)

    end

    # Sending email to procurement initiators about payments against it
    payments = ::Payment.where(payment_order_id: bank_payment_requests.pluck(:payment_order_id)).where.not(purchase_order_id: nil)
    payments.each do |payment|
      Event::EPurchaseOrder::Credit.(user, {payment: payment})
    end
  end
end