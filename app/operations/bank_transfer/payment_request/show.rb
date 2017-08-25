# operation that loads all the details about the payment request

class BankTransfer::PaymentRequest::Show < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_request

  def init
    id = params[:id] || params[:payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id)
  end

  def validate
    if bank_payment_request.blank?
      add_message :error, "Payment order not found"
      return
    end
  end

  def process

  end

  def success

  end

  class BankTransfer::PaymentRequest::Show::RequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :payment_request, :payment_order

    def init
      self.payment_request = params[:payment_request]
      self.payment_order = payment_request.payment_order
    end
  end
end