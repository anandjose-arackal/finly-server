class BankTransfer::PaymentRequest::Review::Retract < BankTransfer::PaymentRequest::Review::Base

  def personalizer
    {
        validate: {
            before: Personalizer::Process.new([:bank_transfer, :payment_request, :review, :retract], :validate, self)
        }
    }
  end

  def authorized_user_types
    [:vendor_payments_initiator]
  end

  def validate
    unless bank_payment_request.owner_id == user.id
      add_message :error, "Only Owners can retract their report"
      return
    end

    unless bank_payment_request.can_retract?
      add_message :error, "Payment Order cannot be retracted in this state"
      return
    end
  end

  def process

    # if bank_payment_request.update status_id: BankPaymentRequestStatus.id_for(:retracted),
    #                                controlling_user_id: user.id,
    #                                controlling_user_role_id: UserRole.id_for(:employee),
    #                                controlling_for_user_id: nil,
    #                                controlling_for_user_role_id: nil
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                                                           action_user_role_id: UserRole.id_for(:employee),
    #                                                           action_id: BankPaymentRequestTrailAction.id_for(:retract)
    #   return true
    # end
    # add_message :error, bank_payment_request.errors.full_messages

    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'retract'
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
                                         action_id: BankPaymentRequestCommentAction.id_for(:retract)

    role_id = self.workflow_output[:role_id]
    Event::EBankPaymentRequest::Retract.(user, bank_payment_request: bank_payment_request, role_id: role_id)
    add_message :success, "Payment Order retracted successfully"
  end

end