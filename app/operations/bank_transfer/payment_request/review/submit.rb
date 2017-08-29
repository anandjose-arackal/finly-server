class BankTransfer::PaymentRequest::Review::Submit < BankTransfer::PaymentRequest::Review::Base

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
  end

  def pre_process
    # #### todo - temporary until we implement the flow for anyone along the approcal chain to credit the money
    # creditor = User::Team::Approver.(bank_payment_request.owner, payment_request: bank_payment_request, type: :finance_manager)
    # fowards_credits_to = nil
    # unless creditor.nil?
    #   forwards_credits_to = User::Team::Approver.(creditor, payment_request: bank_payment_request, type: :approves_finance_to)
    # end
    # debugger
    # if forwards_credits_to.present?
    #   bank_payment_request.payment_order.payments.update_all(initiating_account_id: forwards_credits_to.bank_wallet, initiating_account_type: "VendorPaymentWallet")
    # elsif creditor.present?
    #   bank_payment_request.payment_order.payments.update_all(initiating_account_id: creditor.bank_wallet, initiating_account_type: "VendorPaymentWallet")
    # else
    #   # nothing changes
    # end
    ########################################################################################################
  end

  def process

    presenter = User::Team::Review::NextReviewer.(bank_payment_request)
    manager = presenter.user
    manager_role_id = presenter.role_id
    #######################################
    if manager.nil?
      # i.e. if there is no manager, the payment request directly goes to approved state
      approve_op = BankTransfer::PaymentRequest::Review::Approve.(user, id: bank_payment_request.id, auto_approve: true)
      unless approve_op.success?
        add_message :error, approve_op.messages[:error]
        return false
      end
      return true
    end

    # if there is a manager after all
    submitted_at = DateTime.now
    if bank_payment_request.update_attributes status_id: BankPaymentRequestStatus.id_for(:processing),
                                              controlling_user_id: manager&.id,
                                              controlling_user_role_id: manager_role_id,
                                              submitted_at: submitted_at

      bank_payment_request.bank_payment_request_trails.create action_user: user,
                                         action_user_role_id: UserRole.id_for(:employee),
                                         action_id: BankPaymentRequestTrailAction.id_for(:submit),
                                         modified_user_id: manager&.id,
                                         modified_user_role_id: manager_role_id
      return true
    end
    add_message :error, bank_payment_request.errors.full_messages
  end

  def post_process
    add_message :success, "Payment Order successfully submitted!"
  end


end