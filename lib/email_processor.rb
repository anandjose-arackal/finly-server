# Encapsulates functionality for receiving emails
class EmailProcessor
  def initialize(email)
    @email = email
  end

  def process
    user = User.find_by_email(@email.from[:email])
    if user.present?
      # receipt_email = user.receipt_emails.create  subject: @email.subject,
      #                                             body: @email.body,
      #                                             raw_text: @email.raw_body,
      #                                             raw_html: @email.raw_html,
      #                                             raw_headers: @email.raw_headers,
      #                                             sent_at: DateTime.parse(@email.headers['Date'])

      receipt_email = user.receipt_emails.create  subject: @email.subject,
                                                 sent_at: DateTime.parse(@email.headers['Date'])
      id = receipt_email.id
      receipt_email.body = get_temp_file "#{id}_body.txt", @email.body
      receipt_email.raw_text = get_temp_file "#{id}_raw_text.txt", @email.raw_body
      receipt_email.raw_html = get_temp_file "#{id}_raw_html.txt", @email.raw_html
      receipt_email.raw_header = get_temp_file "#{id}_raw_header.txt", @email.raw_headers
      receipt_email.save
      if @email.attachments.any?
        @email.attachments.each do |attachment|
          receipt_email.receipt_email_attachments.create(original_attachment: attachment)
        end
      end
      receipt_email.save_receipt_image
    end
  end

  protected
  def get_temp_file(filename, string)
    file = Tempfile.new( [filename, '.txt'] )
    file.write( string.force_encoding('utf-8') )
  end
end
