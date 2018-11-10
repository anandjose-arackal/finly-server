class BankTransfer::PaymentRequest::PaymentsCount < BankTransfer::PaymentRequest::Base

  attr_accessor :payments_count, :bank_payment_request

  class BankTransfer::PaymentRequest::PaymentsCount::PaymentsCountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:payments_count]
    end

  end

  def init
    id = params[:id] || params[:bank_payment_request_id]
    index_params = params.select { |k,v| [:view, :role_id].include? k }
    self.bank_payment_request = BankTransfer::PaymentRequest::Index.(user, index_params).payment_requests.find_by(id: id)
  end

  def validate
    if self.bank_payment_request.blank?
      add_message :error, "Bank Payment request not found"
      return
    end
  end

  def process
    self.payments_count = self.bank_payment_request.payment_order.payments.count
  end

  def success
    self.payments_count
  end

end