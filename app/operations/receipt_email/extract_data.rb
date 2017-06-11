class ReceiptEmail::ExtractData < ReceiptEmail::Base

  def process
    html_body = nil
    sender = self.receipt_email.sender
    time = self.receipt_email.sent_at
    note = self.receipt_email.subject

    if self.receipt_email.raw_html.present?
      html_body = self.receipt_email.raw_html
    elsif self.receipt_email.original_source.present?
      email = Mail.read_from_string(File.read(self.receipt_email.original_source.path))
      html_body = email.html_part.body.decoded
    end

    receipt_email_sender = ReceiptEmailSender.having_email_id(sender)
    if receipt_email_sender.present?
      template = receipt_email_sender.receipt_email_template
    else
      # String search to find sender
    end
  end

end