class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@finly.io',
          "Message-ID" => ->(v) {"<#{Digest::SHA2.hexdigest(Time.now.to_i.to_s)}@finly.io>"}

  before_action :add_headers
  after_action :log_mail

  layout 'mailer'

  def add_headers
    headers['X-SES-CONFIGURATION-SET'] = 'email_tracker_core'
  end

  # def log_mail
  #   mail = self.message
  #   mailer_klass = self.class.to_s
  #   mailer_action = self.action_name
  #
  #   if mail.multipart?
  #     body = mail.html_part.decoded
  #   else
  #     body = mail.body.raw_source
  #   end
  #
  #   email = Email.create(
  #       entity: params&.dig(:entity),
  #       company: params&.dig(:company),
  #       user: params&.dig(:user),
  #       message_id: mail.message_id,
  #       sender: mail.from,
  #       recipient: mail.to,
  #       bcc: mail.bcc,
  #       cc: mail.cc,
  #       subject: mail.subject,
  #       body: body,
  #       configuration_set: headers['X-SES-CONFIGURATION-SET'],
  #       mailer_klass: mailer_klass,
  #       mailer_action: mailer_action,
  #       sent_at: mail.date
  #   )
  #
  #   # Todo save attachments
  #
  #   unless email.valid?
  #     raise email.errors.full_messages.join(', ')
  #   end
  #   email
  # end
end
