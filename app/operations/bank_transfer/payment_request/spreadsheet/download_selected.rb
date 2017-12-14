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

  def validate
    if self.bank_payment_requests.empty?
      add_message :error, "No payment orders passed"
    end
  end

  def process
    headers = retrieve_headers
    content = retrieve_data
    self.response = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages)
  end
end
