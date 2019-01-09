class BankTransfer::PaymentRequest::Review::TakeControl < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :take_control_note

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.admin_associated_items(user).find_by id: id
    self.take_control_note = params[:note]
  end

  def validate
    unless user.vendor_payment_admin?
      add_message :error, "Only admins can take control of a report"
      return
    end

    unless bank_payment_request.can_take_control?
      add_message :error, "Payment requets cannot be taken control of at this stage"
      return
    end
  end


  def process
    # if bank_payment_request.update controlling_user: user,
    #                                controlling_for_user: bank_payment_request.controlling_user,
    #                                controlling_user_role_id: UserRole.id_for(:admin),
    #                                controlling_for_user_role_id: bank_payment_request.controlling_user_role_id
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: UserRole.id_for(:admin),
    #                                                           modified_user_id: bank_payment_request.controlling_for_user,
    #                                                           modified_user_role_id: bank_payment_request.controlling_for_user_role_id,
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:take_control)
    #
    #   return
    # end
    # add_message :error, bank_payment_request.errors.full_messages

    ##################
    # NEW CODE
    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'take_control'
    params[:violation_present] = false # Will be used in future
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:take_control),
                                         note: self.take_control_note

    Event::EBankPaymentRequest::TakeControl.(user, bank_payment_request: bank_payment_request)

    add_message :success, "Report taken control of successfully!"
  end


end