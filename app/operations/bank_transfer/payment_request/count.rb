class BankTransfer::PaymentRequest::Count < BankTransfer::PaymentRequest::Base

  attr_accessor :payment_request_ids, :payment_requests_count, :status_counts

  def init

  end

  def process
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      # self.payment_request_ids = op.payment_requests&.pluck(:id)
      self.payment_requests_count = op.payment_requests&.pluck(:id).count rescue 0
    else
      add_message :error, op.messages[:error]
    end
    # self.payment_requests_count = BankPaymentRequest.with_id(payment_request_ids)&.count
    self.status_counts = op&.status_count
  end

  def success
    # payment_requests_count
    # status_counts
    params[:count] = self.payment_requests_count
    params[:status_counts] = self.status_counts
    BankTransfer::PaymentRequest::CountPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count, :status_counts

    def init
      self.count = params[:count]
      self.status_counts = params[:status_counts]
    end
  end
end