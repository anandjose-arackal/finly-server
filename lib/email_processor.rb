# Encapsulates functionality for receiving emails
class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    user = User.find_by_email(@email.from[:email])
    if user.present?
      receipt_email = user.receipt_emails.create  subject: @email.subject,
                                                  body: @email.body,
                                                  raw_text: @email.raw_body,
                                                  raw_html: @email.raw_html,
                                                  raw_headers: @email.raw_headers,
                                                  sent_at: DateTime.parse(@email.headers['Date'])
      if @email.attachments.any?
        @email.attachments.each do |attachment|
          receipt_email.receipt_email_attachments.create(original_attachment: attachment)
        end
      end
      receipt_email.save_receipt_image
    end
  end
end
