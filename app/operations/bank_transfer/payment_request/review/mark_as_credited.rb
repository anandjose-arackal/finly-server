class BankTransfer::PaymentRequest::Review::MarkAsCredited < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :view_role

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
    super
    self.view_role = UserRole.id_for(params[:view].to_sym)
  end

  def process
    if bank_payment_request.update(status_id: BankPaymentRequestStatus.id_for(:credited))
      # create the trail for the same
      bank_payment_request.bank_payment_request_trails.create action_user: user,
                                                              action_user_role_id: self.view_role,
                                                              action_id: BankPaymentRequestTrailAction.id_for(:mark_as_credited),
                                                              modified_user_id: nil,
                                                              modified_user_role_id: nil
    else
      add_message :error, bank_payment_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Payment request marked as credited"
  end
end