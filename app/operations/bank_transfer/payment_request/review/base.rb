class BankTransfer::PaymentRequest::Review::Base < BaseOperation

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankPaymentRequest.find_by(id: id)
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
      return
    end
  end

  
end