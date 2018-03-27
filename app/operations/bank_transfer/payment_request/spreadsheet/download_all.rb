class BankTransfer::PaymentRequest::Spreadsheet::DownloadAll < BankTransfer::PaymentRequest::Spreadsheet::Base

  def init
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.bank_payment_requests = op.payment_requests
    else
      add_message :error, op.messages[:error]
    end
  end

end
