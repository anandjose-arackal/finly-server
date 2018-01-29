class BankTransfer::PaymentRequest::Spreadsheet::DownloadAll < BankTransfer::PaymentRequest::Spreadsheet::Base

  def init
    op = BankTransfer::PaymentRequest::Index.(user, params)
    if op.success?
      self.bank_payment_requests = op.payment_requests
    else
      add_message :error, op.messages[:error]
    end
  end

  def validate
    if self.bank_payment_requests.empty?
      add_message :error, 'No payment orders passed'
    end
  end

  def process
    headers = retrieve_headers
    content = retrieve_data
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end
end
