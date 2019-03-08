# Approve And Forward will not be used as it breaks the approval flow by skipping people in the chain of approval

class BankTransfer::PaymentRequest::Review::ApproveAndForward < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :forwarded_to_user, :forwarded_note

  def init
    super
    forwarded_to_user_id = params[:forward_to_user_id]
    self.forwarded_to_user = user.company.users.find_by(id: forwarded_to_user_id)
    self.forwarded_note = params[:note]
  end

  def validate
    unless forwarded_to_user.vendor_payments_admin?
      add_message :error, "You can only forward this request to admins"
      return
    end

  end

  def process
    current_user_role = User::Team::Review::UserRole.(user, bank_payment_request)
    if bank_payment_request.update controlling_user: forwarded_to_user,
                                   controlling_user_role_id: UserRole.id_for(:admin),
                                   controlling_for_user: nil,
                                   controlling_for_user_role_id: nil
      bank_payment_request.trails.create action_user: user,
                                                      action_user_role_id: current_user_role,
                                                      modified_user: forwarded_to_user,
                                                      modified_user_role_id: UserRole.id_for(:admin),
                                                      action_id: BankPaymentRequestTrailAction.id_for(:approve_and_forward)
    end

    add_message :error, bank_payment_request.errors.full_messages
  end

  def post_process
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:forward),
                                         forwarded_to_user_id: self.forwarded_to_user.id,
                                         note: self.forwarded_note



    add_message :success, "Forwarded to #{forwarded_to_user.name}"
  end
end