class BankTransfer::PaymentRequest::Spreadsheet::DownloadPendingAttachment < BankTransfer::PaymentRequest::Spreadsheet::DownloadPending

  attr_accessor :files

  def process
    headers = retrieve_headers
    content = retrieve_data
    self.files = []
    exported_xls = Exporter.new(user, {spreadsheet: {headers: headers, contents: content}}, messages).spreadsheet_exporter.generate_xls
    self.files << {name: 'export.xls', file_contents: exported_xls}
    bank_payment_requests.include_attachments.each do |bpr|
      file_name_prefix = "#{bpr.id}_"
      count = 1
      bpr.payment_order.payment_order_attachments.each do |attachment|
        file = attachment.attached_file
        extension = attachment.attached_file_file_name.split('.')&.last
        self.files << {name: "#{file_name_prefix}_#{count}.#{extension}", path: file.path}
        count += 1
      end
      bpr.payment_order.payments.each do |payment|
        invoice = payment.invoice
        count = 1
        invoice.invoice_attachments.each do |attachment|
          file = attachment.attached_file
          extension = attachment.attached_file_file_name.split('.')&.last
          self.files << {name: "#{file_name_prefix}_payment_#{count}.#{extension}", path: file.path}
          count += 1
        end
      end
    end
  end

  def success
    Exporter::AsZip.new(user, {files: self.files}, messages)
  end

end
