class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@finlyhq.com',
          "Message-ID" => ->(v) { "<#{SecureRandom.hex(32)}#{DateTime.now.strftime('%H%M%S%L')}@finlyhq.com>" }

  before_action :add_headers
  after_action :log_mail

  layout 'mailer'

  def add_headers
    headers['X-SES-CONFIGURATION-SET'] = 'email_tracker_core'
  end

  def company
    RequestStoreUtil.current_company
  end

  def log_mail
    mail = self.message
    mailer_klass = self.class.to_s
    mailer_action = self.action_name

    if mail.multipart?
      body = mail.html_part.decoded
    else
      body = mail.body.raw_source
    end

    email = Email.create(
      entity: params&.dig(:entity),
      company: self.company,
      message_id: mail.message_id,
      sender: mail.from,
      recipient: mail.to,
      bcc: mail.bcc,
      cc: mail.cc,
      subject: mail.subject,
      configuration_set: headers['X-SES-CONFIGURATION-SET'],
      mailer_klass: mailer_klass,
      mailer_action: mailer_action,
      sent_at: mail.date
    )

    email_body = email.create_body(company: self.company, body: body)
    debugger

    # Todo save attachments

    unless email.valid?
      raise email.errors.full_messages.join(', ')
    end
    email
  end
end
