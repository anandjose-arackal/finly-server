class BankTransfer::PaymentRequest::Spreadsheet::DownloadPendingAttachment < BankTransfer::PaymentRequest::Spreadsheet::DownloadPending

  def process
    self.include_attachments = true
    super
  end

end
