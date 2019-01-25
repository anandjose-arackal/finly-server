class BankTransfer::PaymentRequest::Review::Submit < BankTransfer::PaymentRequest::Review::Base

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

    # Set validation of DLRMs
    dlrm_validation_op = ReviewalManager::DocumentReviewalMappings::Validate.(user, {
        reviewal_document: self.bank_payment_request
    })

    unless dlrm_validation_op.success?
      add_message :error, dlrm_validation_op.messages[:error]
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

    Event::EBankPaymentRequest::Submit.(user, bank_payment_request: bank_payment_request)
    add_message :success, "Payment Order successfully submitted!"
  end


end