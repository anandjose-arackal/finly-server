# this operation is the reverse of take control, in the sense that it return control to whoever the person
# was from whom control was taken
class BankTransfer::PaymentRequest::Review::ReturnControl < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :return_control_note

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.admin_associated_items(user).find_by id: id
    self.return_control_note = params[:note]
  end

  def validate
    unless user.vendor_payment_admin?
      add_message :error, "Only admins can return control of a payment order"
      return
    end

    unless bank_payment_request.can_return_control?
      add_message :error, "Payment orders cannot be returned control of at this stage"
      return
    end

    # unless self.bank_payment_request.controlling_user_id == self.user.id
    #   add_message :error, "Only the current reviewer can return control of a payment order"
    #   return
    # end

    # unless self.bank_payment_request.controlling_for_user.present?
    #   add_message :error, "Payment Order not configured properly while taking control"
    # end
  end


  def process
    # previous_reviewer = self.bank_payment_request.controlling_for_user
    # previous_reviewer_role_id = self.bank_payment_request.controlling_for_user_role_id
    # if bank_payment_request.update controlling_user: previous_reviewer,
    #                                controlling_for_user: nil,
    #                                controlling_user_role_id: previous_reviewer_role_id,
    #                                controlling_for_user_role_id: nil
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: UserRole.id_for(:admin),
    #                                                           modified_user_id:previous_reviewer.id,
    #                                                           modified_user_role_id: previous_reviewer_role_id,
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:return_control)
    #
    #   return
    # end
    # add_message :error, bank_payment_request.errors.full_messages

    ##################
    # NEW CODE
    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'return_control'
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
                                         action_id: BankPaymentRequestCommentAction.id_for(:return_control),
                                         note: self.return_control_note

    # Event::EBankPaymentRequest::ReturnControl.(user, bank_payment_request: bank_payment_request)

    add_message :success, "Payment Order control returned successfully"
  end
end