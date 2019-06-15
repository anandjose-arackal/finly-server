class ExpressionEvaluator::Context::Documents::PaymentTicket < ExpressionEvaluator::Context::Base

  alias_method :bank_payment_request, :data

  def self.accept?(data=nil)
    data and data.class.name == BankPaymentRequest.name
  end

end