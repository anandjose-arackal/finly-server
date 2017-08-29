class BankTransfer::PaymentRequest::Review::ApproveAndForward < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :forwarded_to_user

  def init
    super
    forwarded_to_user_id = params[:forwarded_to_user_id]
    self.forwarded_to_user = user.company.users.find_by(id: forwarded_to_user_id)
  end

  def validate
    unless forwarded_to_user.vendor_payments_admin?
      add_message :error, "You can only forward this request to admins"
      return
    end

    # unless bank_payment_request.can_forward?
    #   add_message :error, "Payment Request cannot be forwarded in this state"
    #   return
    # end
  end

  def process
    current_user_role = User::Team::Review::UserRole.(user, bank_payment_request)
    if bank_payment_request.update controlling_user: forwarded_to_user,
                                   controlling_user_role: UserRole.id_for(:admin),
                                   controlling_for_user: nil,
                                   controlling_for_user_role_id: nil
      bank_payment_request.bank_payment_trails.create action_user: user,
                                                      action_user_role_id: current_user_role,
                                                      modified_user: forwarded_to_user,
                                                      modified_user_role_id: UserRole.id_for(:admin),
                                                      action_id: BankPaymentRequestTrailAction.id_for(:approved_and_forwarded)
    end
    add_message :error, bank_payment_request.errors.full_messages
  end

  def post_process
    add_message :error, "Forwarded to #{forwarded_to_user.name}"
  end
end