class BankTransfer::PaymentRequest::Review::BulkCredit < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_requests, :result

  def init
    ids = params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(",")
    end
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.payment_requests = op.payment_requests.creditable.with_id(ids)
    else
      add_message :error, op.messages[:error]
    end
  end

  def validate
    if self.payment_requests.empty?
      add_message :error, "Payment orders not found"
      return
    end
  end

  def process
    # update the status of all payment orders as pending
    self.payment_requests.update_all(status_id: BankPaymentRequestStatus.id_for(:pending))
    ids = self.bank_payment_requests.pluck(:id)
    BankTransfer::PaymentRequest::Review::CreditBackground.call_async(ids, initiating_user_id: user.id)
  end

  def post_process
    add_message :success, "Payment Orders credit initiated"
  end

end