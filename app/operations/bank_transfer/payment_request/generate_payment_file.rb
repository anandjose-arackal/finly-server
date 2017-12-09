class BankTransfer::PaymentRequest::GeneratePaymentFile < BankTransfer::PaymentRequest::Base

  attr_accessor :bank_payment_requests, :payment_file_data

  def init
    # the input here will be either a comma separated set of values or
    ids = params[:bank_payment_request_ids]
    unless id.is_a?(Array)
      ids = ids.split(",")
    end
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
  end

  def process
    params[:bank_payment_requests] = self.bank_payment_requests
    self.response = PaymentFiles::Generate.(user, params)
  end

end