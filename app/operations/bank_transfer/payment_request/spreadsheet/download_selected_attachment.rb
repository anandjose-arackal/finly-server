class BankTransfer::PaymentRequest::Spreadsheet::DownloadSelectedAttachment < BankTransfer::PaymentRequest::Spreadsheet::DownloadSelected

  def process
    self.include_attachments = true
    super
  end

end
