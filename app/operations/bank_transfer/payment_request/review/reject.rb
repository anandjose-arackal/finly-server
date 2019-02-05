class BankTransfer::PaymentRequest::Review::Reject < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :rejection_note

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.reviewer_associated_items(user).find_by id: id
    self.rejection_note = params[:note]
  end

  def validate
    unless bank_payment_request.can_reject?
      add_message :error, "Payment Order cannot be rejected at this state"
      return
    end

    ##################
    # OLD CODE
    # unless bank_payment_request.controlling_user_id == user.id
    #   add_message :error, "You cannot reject this payment Order"
    #   return
    # end
  end

  def process
    # current_user_role = nil
    # if bank_payment_request.update status_id: BankPaymentRequestStatus.id_for(:rejected),
    #                                controlling_user_id: bank_payment_request.owner_id,
    #                                controlling_user_role_id: UserRole.employee_id,
    #                                controlling_for_user_id: nil,
    #                                controlling_for_user_role_id: nil
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: current_user_role,
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:reject),
    #                                                           modified_user_id: bank_payment_request.owner_id,
    #                                                           modified_user_role_id: UserRole.employee_id
    #   return true
    # end
    # add_message :error, bank_payment_request.errors.full_messages

    #####################
    # NEW CODE
    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'reject'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    # add comments
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:reject),
                                         note: rejection_note
    role_id = self.workflow_output[:role_id]
    Event::EBankPaymentRequest::Reject.(user, bank_payment_request: bank_payment_request, role_id: role_id)

    add_message :success, "Payment Request successfully rejected"
  end
end