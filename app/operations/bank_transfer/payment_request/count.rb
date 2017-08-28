class BankTransfer::PaymentRequest::Count < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_request_ids, :payment_requests_count

  def init

  end

  def process
    op = BankTransfer::PaymentRequest::Index.(current_user, params)
    if op.success?
      self.payment_request_ids = op.payment_requests.pluck(:id)
    else
      add_message :error, op.messages[:error]
    end
    self.payment_requests_count = BankPaymentRequest.with_id(payment_request_ids).count
  end

  def success
    payment_requests_count
  end
end