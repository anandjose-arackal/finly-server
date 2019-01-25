class BankTransfer::PaymentRequest::Review::Approve < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :auto_approve

  def authorized_user_type
    [:manager, :finance_manager, :admin]
  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.reviewer_associated_items(user).find_by id: id
  end

  def validate
    # OLD CODE
    # unless bank_payment_request.controlling_user_id == user.id
    #   add_message :error, "You are not eligible to perform this action"
    #   return
    # end
    # unless bank_payment_request.can_approve? || params[:auto_approve]
    #   add_message :error, "Payment Order cannot be approved in this state"
    #   return
    # end
  end

  def process
    # presenter = User::Team::Review::NextReviewer.(bank_payment_request)
    # next_reviewer = presenter.user
    # next_reviewer_role_id = presenter.role_id
    # # this returns the role under which this particular user is viewing the payment request
    # current_user_role = User::Team::Review::UserRole.(user, self.bank_payment_request)
    # if next_reviewer.nil?
    #   payment_status = BankPaymentRequestStatus.id_for(:approved)
    # else
    #   payment_status = BankPaymentRequestStatus.id_for(:processing)
    # end
    # action_for_user_id = bank_payment_request.controlling_for_user_id
    # action_for_user_role_id = bank_payment_request.controlling_for_user_role_id
    # if bank_payment_request.update status_id: payment_status,
    #                                controlling_user: next_reviewer,
    #                                controlling_user_role_id: next_reviewer_role_id,
    #                                controlling_for_user_id: nil,
    #                                controlling_for_user_role_id: nil,
    #                                auto_approved: self.auto_approve
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: current_user_role,
    #                                                           action_for_user_id: action_for_user_id,
    #                                                           action_for_user_role_id: action_for_user_role_id,
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:approve),
    #                                                           modified_user_id: next_reviewer&.id,
    #                                                           modified_user_role_id: next_reviewer_role_id
    #   return true
    # end
    # add_message :error, bank_payment_request.errors.full_messages

    #####################
    # NEW CODE
    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'approve'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    if self.auto_approve
      action_id = BankPaymentRequestCommentAction.id_for(:auto_approve)
    else
      action_id = BankPaymentRequestCommentAction.id_for(:approve)
    end
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: action_id

    Event::EBankPaymentRequest::Approve.(user, bank_payment_request: bank_payment_request)

    add_message :success, "Succesfully approved the payment request"
  end

end