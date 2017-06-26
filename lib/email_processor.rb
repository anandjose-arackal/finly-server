require 'fake_file_i_o'
# Encapsulates functionality for receiving emails
class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    user = User.find_by_email(@email.from[:email])
    return unless user.present?
    # receipt_email = user.receipt_emails.create  subject: @email.subject,
    #                                             body: @email.body,
    #                                             raw_text: @email.raw_body,
    #                                             raw_html: @email.raw_html,
    #                                             raw_headers: @email.raw_headers,
    #                                             sent_at: DateTime.parse(@email.headers['Date'])

    receipt_email = user.receipt_emails.create subject: @email.subject,
                                               sent_at: DateTime.parse(@email.headers['Date'])
    id = receipt_email.id
    receipt_email.body = FakeFileIO.new("#{id}_body.txt", @email.body)
    receipt_email.raw_text = FakeFileIO.new("#{id}_raw_body.txt", @email.raw_body)
    receipt_email.raw_html = FakeFileIO.new("#{id}_raw_html.txt", @email.raw_html)
    receipt_email.raw_header = FakeFileIO.new("#{id}_raw_headers.txt", @email.raw_headers)
    receipt_email.save
    if @email.attachments.any?
      @email.attachments.each do |attachment|
        receipt_email.receipt_email_attachments.create(original_attachment: attachment)
      end
    end
    # receipt_email.save_receipts
    Receipt::ReceiptEmails::ProcessEmail.(user, receipt_email_id: receipt_email.id)
  end
end
