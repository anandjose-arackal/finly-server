class ApplicationMailer < ActionMailer::Base
  default from: 'noreply@finlyhq.com',
          'Message-ID' => ->(v) { "<#{SecureRandom.hex(32)}#{DateTime.now.strftime('%H%M%S%L')}@finlyhq.com>" }

  before_action :add_headers
  around_action :set_non_tenant
  after_action :log_mail

  layout 'mailer'

  def set_non_tenant(&block)
    ActsAsTenant.without_tenant(&block)
  end

  def run_without_tenant(&block)
    ActsAsTenant.without_tenant(&block)
  end

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

    body = mail.multipart? ? mail.html_part.decoded : mail.body.raw_source

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

    email.create_body(company: self.company, body: body)

    # Todo save attachments

    unless email.valid?
      raise email.errors.full_messages.join(', ')
    end

    email
  end

  def process_action(*args)
    mail_logger = LogStashLogger.new(type: :file, path: 'log/mail_logs.log', sync: true)
    begin
      mail_logger.info({ log_type: 'mailer_obj_size_tracker',
                         class_name: self.class.name,
                         method: args[0],
                         params_size: ObjectSpace.memsize_of(args[1]),
                         params_parts_size: args[1].map { |k, v| "#{k}- #{v.to_s.size}" }.join(' | ') })
    rescue StandardError => e
      mail_logger.info({ log_type: 'mailer_obj_size_tracker',
                         class_name: self.class.name,
                         comment: 'Error Occurred, hence logging only object size',
                         method: args[0],
                         params_size: ObjectSpace.memsize_of(args[1]) })
    end

    super
  end
end
