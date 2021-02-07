class Event::EAlert::Create < Event::EAlert::Base

  def pre_validate
    if params.blank? or (params[:title].blank? and params[:description].blank?)
      add_message :error, 'Nothing to send'
      return
    end
  end

  def affected_users
    if Rails.env.production?
      emails = %w(vivek.a@finly.io sreeram.nr@finly.io kumar.abinash@finly.io prakash.thakur@finly.io)
    else
      emails = %w(sreeram.nr@finly.io kumar.abinash@finly.io)
    end
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
    return unless params[:subject].present? and (params[:title].present? or params[:description].present?)
    AlertMailer.delay.send_mail(Event::EAlert::Create::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
    params[:subject]
  end

  def mailer_body(user)
    params[:title]
  end

  def mailer_button_name(user)
  end

  def set_presenter_params(user)
    params[:subject] = "Server Alert - #{params[:subject]}"
    params[:title] = params[:title]
    params[:description] = params[:description]
  end

  class Event::EAlert::Create::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor  :body_title, :body_description, :subject, :company

    def initialize(user, params)
      self.user = user
      self.body_title = params[:title]
      self.body_description = params[:description]
      self.subject = params[:subject]
      self.company = Company.second
    end

    def validate
      self.body_title.present? or self.body_description.present?
    end

    def to
      self.user.email
    end

  end

end
