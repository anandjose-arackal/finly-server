class BankTransfer::PaymentRequest::Spreadsheet::DownloadSelected < BankTransfer::PaymentRequest::Spreadsheet::Base

  def init
    ids = params[:bank_payment_request_ids]
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.bank_payment_requests = op.payment_requests.with_id(ids)
    else
      add_message :error, op.messages[:error]
    end
  end

end
