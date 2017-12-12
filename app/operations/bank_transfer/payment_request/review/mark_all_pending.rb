class BankTransfer::PaymentRequest::Review::MarkAllPending < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result

  def pre_validate

  end

  def init
    ids = params[:ids] || params[:bank_payment_request_ids]
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    self.bank_payment_requests = self.bank_payment_request.includes_details
    self.processing_status_id = BankPaymentRequestStatus.id_for(:processing)
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
    end
  end

  def process
    # update the status of all payment orders as pending
    self.bank_payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    ids = self.bank_payment_requests.pluck(:id)
    # BankTransfer::PaymentRequest::Review::ApproveBackground.call_async(ids, initiating_user: user)
    BankTransfer::PaymentRequest::Review::ApproveBackground.call(ids, initiating_user: user)
  end

  def post_process
    add_message :sucess, "Payment orders have been marked for approval"
  end
end