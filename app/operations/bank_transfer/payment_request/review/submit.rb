class BankTransfer::PaymentRequest::Review::Submit < BankTransfer::PaymentRequest::Review::Base
  attr_accessor :payable_amounts, :payment_to_invoices, :inward_invoices, :payment_ids

  def personalizer
    {
        validate: {
            before: Personalizer::Process.new([:bank_payment_requests, :submit], :validate, self)
        }
    }
  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = user.bank_payment_requests.find_by id: id
    self.payment_order = bank_payment_request&.payment_order

    self.payable_amounts = {}
    ids = []
    self.payment_ids = []
    self.payment_to_invoices = {}
    self.bank_payment_request.payment_order.payments.each do |payment|
      break unless payment.parent_type == 'Invoice'
      payment_ids << payment.id
      ids << payment.parent_id
      self.payment_to_invoices[payment.parent_id.to_i] = payment
      self.payable_amounts[payment.parent_id.to_i] = payment.amount&.value.to_f
    end

    self.inward_invoices = user.company.inward_invoices.with_id(ids)
  end


  def validate
    unless bank_payment_request.present?
      add_message :error, "Payment Order not found"
      return
    end

    unless bank_payment_request.can_submit?
      add_message :error, "Payment Order cannot be submitted at this time"
      return
    end

    unless bank_payment_request.payment_order.payments.present?
      add_message :error, "Cannot submit an empty payment order"
    end

    unless bank_payment_request.owner_id == user.id
      add_message :error, "Only owner can submit a Payment order"
      return false
    end

    invoices = self.inward_invoices.where(invoice_status_id: InwardInvoiceStatus.id_for(:voided))
    if invoices.present?
      add_message :error, "Payments with IDs #{payment_ids.join(", ")} have invoices which are voided. Please remove them before taking any action."
      return
    end

    # Set validation of DLRMs
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Validate.(user, {
        reviewal_document: self.bank_payment_request
    })

    unless dlrm_validation_op.success?
      add_message :error, dlrm_validation_op.messages[:error]
    end

    self.payable_amounts.each do |invoice_id, payable_amount|
      invoice = self.inward_invoices.find_by(id: invoice_id)
      remaining_amount = (invoice.balance_due&.value.to_f - invoice.payments.successful.joins(:amount).sum(:value)).round(2)
      paid_amount = invoice.payments.successful.joins(:amount).sum(:value).round(2)

      if remaining_amount.blank?
        next
      end

      if payable_amount.round(2) > remaining_amount
        add_message :error, "You cannot pay more than the remaining amount in an invoice. Payment with id, #{self.payment_to_invoices[invoice.id]&.id}, cannot be processed."
      end

      if paid_amount >= invoice.balance_due&.value.to_f
        add_message :error, "Invoice has been credited. Payment with id, #{self.payment_to_invoices[invoice.id]&.id}, cannot be processed."
        return
      end
    end

  end

  def pre_process
  end

  def process
    # presenter = User::Team::Review::NextReviewer.(bank_payment_request)
    # manager = presenter.user
    # manager_role_id = presenter.role_id
    # #######################################
    # if manager.nil?
    #   # i.e. if there is no manager, the payment request directly goes to approved state
    #   # create a submit trail for the payment request
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: UserRole.id_for(:employee),
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:submit),
    #                                                           modified_user_id: manager&.id,
    #                                                           modified_user_role_id: manager_role_id
    #   approve_op = BankTransfer::PaymentRequest::Review::Approve.(user, id: bank_payment_request.id, auto_approve: true)
    #   unless approve_op.success?
    #     add_message :error, approve_op.messages[:error]
    #     return false
    #   end
    #   return true
    # end
    #
    # # if there is a manager after all
    # submitted_at = DateTime.now
    # if bank_payment_request.update_attributes status_id: BankPaymentRequestStatus.id_for(:processing),
    #                                           controlling_user_id: manager&.id,
    #                                           controlling_user_role_id: manager_role_id,
    #                                           submitted_at: submitted_at
    #
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                      action_user_role_id: UserRole.id_for(:employee),
    #                                      action_id: BankPaymentRequestTrailAction.id_for(:submit),
    #                                      modified_user_id: manager&.id,
    #                                      modified_user_role_id: manager_role_id
    #   return true
    # end
    # add_message :error, bank_payment_request.errors.full_messages

    ####################
    # NEW CODE
    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'submit'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.bank_payment_request.update(rejection_note: "")
    self.workflow_output = op.workflow_output

    # todo create bank_payment_request_trail
    #   # i.e. if there is no manager, the payment request directly goes to approved state
    #   # create a submit trail for the payment request
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: UserRole.id_for(:employee),
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:submit),
    #                                                           modified_user_id: manager&.id,
    #                                                           modified_user_role_id: manager_role_id
    #   approve_op = BankTransfer::PaymentRequest::Review::Approve.(user, id: bank_payment_request.id, auto_approve: true)
    #   unless approve_op.success?
    #     add_message :error, approve_op.messages[:error]
    #     return false
    #   end
    #   return true
    # end
    #
    # # if there is a manager after all
    submitted_at = DateTime.now
    bank_payment_request.update_attributes submitted_at: submitted_at

      # bank_payment_request.bank_payment_request_trails.create action_user: user,
      #                                    action_user_role_id: UserRole.id_for(:employee),
      #                                    action_id: BankPaymentRequestTrailAction.id_for(:submit),
      #                                    modified_user_id: manager&.id,
      #                                    modified_user_role_id: manager_role_id
      # return true
    # add_message :error, bank_payment_request.errors.full_messages
  end

  def post_process
    # add comment
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:submit)
    role_id = self.workflow_output[:role_id]
    Event::EBankPaymentRequest::Submit.(user, bank_payment_request: bank_payment_request, role_id: role_id)
    add_message :success, "Payment Order successfully submitted!"
  end


end