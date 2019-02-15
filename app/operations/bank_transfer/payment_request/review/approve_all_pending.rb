class BankTransfer::PaymentRequest::Review::ApproveAllPending < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result

  def pre_validate
    super
    return if has_errors?
    if params[:password].blank?
      add_message :error, 'You need to provide your password to initiate this action'
      return
    end
    unless user.valid_password?(params[:password])
      add_message :error, 'Invalid Password'
      return
    end
  end

  def init
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.bank_payment_requests = op.payment_requests
      # now extract all payment requests for which this particular user is the controlling user
      # self.bank_payment_requests = self.bank_payment_requests.with_controlling_user(user.id).includes_details


      # self.bank_payment_requests = self.bank_payment_requests.with_controlling_user(user.id).includes_details
      self.bank_payment_requests = BankPaymentRequest.awaiting_action_items(user).includes_details
      self.processing_status_id = BankPaymentRequestStatus.id_for(:processing)
    else
      add_message :error, op.messages[:error]
    end
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
    end
  end

  def process
    # update the status of all payment orders that are approvable by current as pending
    self.bank_payment_requests.where.not(status_id: BankPaymentRequestStatus.id_for(:pending)).or(
        self.bank_payment_requests.where.not(controlling_user_id: user.id))
    self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    ids = self.bank_payment_requests.pluck(:id)

    if self.bank_payment_requests.present?
      BankTransfer::PaymentRequest::Review::ApproveBackground.call_async(ids, initiating_user_id: user.id)
    else
      add_message :notice, 'No Payment tickets are awaiting your approval'
    end
  end

  def post_process
    add_message :success, 'Payment orders have been marked for approval'
  end
end