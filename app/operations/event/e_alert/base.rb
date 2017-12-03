class Event::EAlert::Base < Event::SetNotifier

  def pre_validate
    if params.blank? or params[:message].blank?
      add_message :error, 'Nothing to send'
      return
    end
  end

  def affected_users
    emails = %w(vivek.a@finly.io sreeram.nr@finly.io)
    User.with_email(emails)
  end

  def event_id
    NotifierType.id_for(:system_alert)
  end

  def action_name
    'System Alert'
  end

  def init
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    AlertMailer.delay.send_mail(Event::EAlert::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
    params[:subject]
  end

  def mailer_body(user)
    params[:body]
  end

  def mailer_button_name(user)
  end

  def set_presenter_params(user)
    params[:subject] = params[:subject] || 'Server Alert'
    params[:body] = params[:message]
  end

  class Event::EAlert::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor  :body_val, :subject_val, :company

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = Company.second
    end

    def validate
      self.body_val.present?
    end

    def to
      self.user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

  end

end
