class BankTransfer::PaymentRequest::Review::BulkApproveValidate < BankTransfer::PaymentRequest::Review::Base

  class BankTransfer::PaymentRequest::Review::BulkApprove::ApprovePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :errors_found, :result_hash

    def init
      self.errors_found = params[:errors_found]
      self.result_hash = params[:result_hash]
    end

  end

  attr_accessor :bank_payment_requests

  def init
    ids = params[:ids] || params[:bank_payment_request_ids]
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
  end

  def validate

  end

  def process

  end

end
