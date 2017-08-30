class BankTransfer::PaymentRequest::Review::Approve < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :auto_approve

  def authorized_user_type
    [:manager, :finance_manager, :admin]
  end

  def init
    super

  end

  def validate
    unless bank_payment_request.controlling_user_id == user.id
      add_message :error, "You are not eligible to perform this action"
      return
    end

    unless bank_payment_request.can_approve? || params[:auto_approve]
      add_message :error, "Payment Order cannot be submitted in this state"
      return
    end
  end

  def process
    presenter = User::Team::Review::NextReviewer.(bank_payment_request)
    next_reviewer = presenter.user
    next_reviewer_role_id = presenter.role_id
    # this returns the role under which this particular user is viewing the payment request
    current_user_role = User::Team::Review::UserRole.(user, self.bank_payment_request)
    if next_reviewer.nil?
      payment_status = BankPaymentRequestStatus.id_for(:approved)
      self.auto_approve = true
    else
      payment_status = BankPaymentRequestStatus.id_for(:processing)
    end
    if bank_payment_request.update status_id: payment_status,
                                   controlling_user: next_reviewer,
                                   controlling_user_role_id: next_reviewer_role_id
      bank_payment_request.bank_payment_request_trails.create action_user: user,
                                                              action_user_role_id: current_user_role,
                                                              action_id: BankPaymentRequestTrailAction.id_for(:submit),
                                                              modified_user_id: next_reviewer&.id,
                                                              modified_user_role_id: next_reviewer_role_id
      return true
    end
    add_message :error, bank_payment_request.errors.full_messages
  end

  def post_process
    if self.auto_approve
      action_id = BankPaymentRequestCommentAction.id_for(:auto_approve)
    else
      action_id = BankPaymentRequestCommentAction.id_for(:approve)
    end
    bank_payment_request.comments.create action_user_id: user.id,
                                         action_id: action_id

    add_message :success, "Succesfully approved the payment request"
  end

end