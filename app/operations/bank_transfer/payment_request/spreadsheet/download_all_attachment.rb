class BankTransfer::PaymentRequest::Spreadsheet::DownloadAllAttachment < BankTransfer::PaymentRequest::Spreadsheet::DownloadAll

  def process
    self.include_attachments = true
    super
  end

end
