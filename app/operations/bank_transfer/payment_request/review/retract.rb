class BankTransfer::PaymentRequest::Review::Retract < BankTransfer::PaymentRequest::Review::Base

  def authorized_user_types
    [:employee]
  end

  def validate
    unless bank_payment_request.owner_id == user.id
      add_message :error, "Only Owners can retract their report"
      return
    end

    unless bank_payment_request.can_retract?
      add_message :error, "Report cannot be retracted in this state"
      return
    end
  end

  def process

    if bank_payment_request.update status_id: BankPaymentRequestStatus.id_for(:retracted),
                                   controlling_user_id: user.id,
                                   controlling_user_role_id: UserRole.id_for(:employee)
      bank_payment_request.bank_payment_request_trails.create action_user: user,
                                                              action_user_role_id: UserRole.id_for(:employee),
                                                              action_id: BankPaymentRequestTrailAction.id_for(:retract)
      return true
    end
    add_message :error, bank_payment_request.errors.full_messages
  end

  def post_process
    # add comments

    add_message :success, "Payment Order retracted successfully"
  end

end