# Used to download email url attachments and create receipts out of them. Currently not being used.
class ReceiptEmail::ProcessEmail < ReceiptEmail::Base

  def process
    download_attachment_urls
    save_receipts
    ReceiptEmail::ExtractData.call(user, receipt_email_id: self.receipt_email.id)
  end

  protected
  def download_attachment_urls
    self.receipt_email.receipt_email_attachments.each do |attachment|
      if attachment.download_pending?
        url = attachment.attachment_url
        file_name = attachment.attachment_url_file_name
        file_presenter = File::Download.(self.user, url: url, file_name: file_name)
        if file_presenter&.success?
          attachment.update(original_attachment: file_presenter.file)
        else
          attachment.system_messages.create system_message_type_id: SystemMessageType.id_for(:error), content: 'Error downloading attachment'
        end
      end
    end
  end

  def save_receipts
    self.receipt_email.save_receipt_image
  end

end