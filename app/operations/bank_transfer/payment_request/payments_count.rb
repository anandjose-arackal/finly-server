class BankTransfer::PaymentRequest::PaymentsCount < BankTransfer::PaymentRequest::Base

  attr_accessor :payments_count, :bank_payment_request

  class BankTransfer::PaymentRequest::PaymentsCount::PaymentsCountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count, :payments

    has_scope :filter_status_id

    def init
      self.payments = params[:payments]
      self.payments = apply_scopes(self.payments, params)
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
    self.payments = self.bank_payment_request.payment_order.payments
  end

  def success
    params[:payments] = self.payments
    BankTransfer::PaymentRequest::PaymentsCount::PaymentsCountPresenter.new(user, params, messages)
  end

end