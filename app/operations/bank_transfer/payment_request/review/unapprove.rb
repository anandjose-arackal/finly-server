class BankTransfer::PaymentRequest::Review::Unapprove < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :prev_status, :from_user

  def init
    super
    if bank_payment_request.present?
      self.from_user = self.bank_payment_request.controlling_user
    end
  end

  def validate
    # checking if this user can unapprove this payment request at this stage
    # associated_users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: from_user)
    # unless associated_users.present? or associated_users.with_id(user.id).present?
    #   add_message :error, "You haven't approved the Payment Order yet"
    #   return false
    # end


    unless bank_payment_request.processing? || bank_payment_request.approved?
      add_message :error, 'The Payment Order cannot be unapproved at this stage'
    end
  end

  def process
    # prev_controlling_user = (bank_payment_request.controlling_for_user or bank_payment_request.controlling_user)
    # prev_controlling_user_role = User::Team::Review::UserRole.(prev_controlling_user, self.bank_payment_request)
    # role_id = nil
    # if manager_view?
    #   role_id = UserRole.id_for(:manager)
    # elsif finance_view?
    #   role_id = UserRole.id_for(:finance_manager)
    # end
    # self.prev_status = bank_payment_request.status
    # if bank_payment_request.update_attributes controlling_user_id: user.id,
    #                             controlling_for_user_id: nil,
    #                             controlling_user_role_id: role_id,
    #                             controlling_for_user_role_id: nil,
    #                             status_id: BankPaymentRequestStatus.id_for(:processing)
    #
    #   bank_payment_request.bank_payment_request_trails.create action_user: user,
    #                        action_user_role_id: role_id,
    #                        modified_user: prev_controlling_user,
    #                        modified_user_role_id: prev_controlling_user_role,
    #                        action_id: BankPaymentRequestTrailAction.id_for(:unapprove)
    #   return
    # end
    # add_message :error, bank_payment_request.errors.full_messages
    params[:document] = self.bank_payment_request
    params[:aasm_event] = 'unapprove'
    params[:violation_present] = false
    op = WorkflowManager::Base.(user, params)

    unless op.success?
      add_message :error, op.messages[:error]
      return
    end

    self.workflow_output = op.workflow_output
  end

  def post_process
    bank_payment_request.comments.create user_id: user.id,
                                         action_id: BankPaymentRequestCommentAction.id_for(:unapprove)
    role_id = self.workflow_output[:role_id]                                         
    Event::EBankPaymentRequest::Unapprove.(user, bank_payment_request: bank_payment_request, role_id: role_id)

    add_message :success, 'Payment Order unapproved'
  end
end