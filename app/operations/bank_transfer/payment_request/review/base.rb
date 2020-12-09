class BankTransfer::PaymentRequest::Review::Base < BaseOperation

  attr_accessor :bank_payment_request, :payment_order, :workflow_output

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
      return
    end
  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.find_by(id: id) rescue nil
    # self.bank_payment_request = BankPaymentRequest.find_by(id: id)
    self.payment_order = bank_payment_request&.payment_order
  end

  def validate
    if bank_payment_request.blank? || self.payment_order.nil?
      add_message :error, "Payment order not found"
      return
    end
  end

  def success
    params[:bank_payment_request] = self.bank_payment_request
    BankTransfer::PaymentRequest::Review::Base::RequestPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Review::Base::RequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bank_payment_request

    def init
      self.bank_payment_request  = params[:bank_payment_request]
    end
  end
end