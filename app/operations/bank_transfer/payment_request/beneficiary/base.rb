class BankTransfer::PaymentRequest::Beneficiary::Base < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request, :payment_order

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, please try again"
    end
  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id) rescue nil
    self.payment_order = bank_payment_request.payment_order
  end

  def validate
    if self.bank_payment_request.blank? || self.payment_order.blank?
      add_message :error, "Payment Order not found"
    end
  end
end