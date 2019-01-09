class BankTransfer::PaymentRequest::Update::Base < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_request, :payment_order

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)

    self.payment_order = payment_request.payment_order
  end

end