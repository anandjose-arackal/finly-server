class BankTransfer::PaymentRequest::PaymentsInfo < BankTransfer::PaymentRequest::Base

  attr_accessor :payment, :bank_payment_request

  class BankTransfer::PaymentRequest::PaymentsInfo::PaymentsPresenter < BaseOperation::BasePresenter::SuccessPresenter
    
    attr_accessor :payment

    def init
      self.payment = params[:payment]
    end
  end

  def init
    id = params[:id] || params[:payment_id]
    bank_payment_request_id = params[:bank_payment_request_id] || params[:order_id]
    self.bank_payment_request = user.company.bank_payment_requests.find_by_id(bank_payment_request_id)
    self.payment = bank_payment_request.payment_order.payments.find_by_id(id)
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Payment ticket not found"
      return
    end
  end

  def process
  end

  def success
    params[:payment] = self.payment
    BankTransfer::PaymentRequest::PaymentsInfo::PaymentsPresenter.new(user, params, messages)
  end
end