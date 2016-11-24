class Event::EMoneyRequest::Base < Event::SetNotification
  attr_accessor :money_request

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank? or params[:money_request].blank?
      add_message :error, 'Advance Request not found'
    end
    unless params[:money_request].is_a?(::MoneyRequest)
      add_message :error, 'Error loading money_request'
    end
  end

  def init
    self.money_request = params[:money_request]
  end

  def validate
    unless self.money_request.present?
      add_message :error, 'Advance Request not found'
    end
  end

  def send_mailer(user)
    subject = self.mailer_subject(user)
    body = self.mailer_body(user)
    button_name = self.mailer_button_name(user)
    return unless subject.present? and body.present?
    MoneyRequestMailer.delay.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(user, money_request, subject, body, button_name))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    if money_request.controlling_user_id.present? and
        user.id == money_request.controlling_user_id and not user.id == money_request.user.id
      'Review Advance Request'
    else
      'View Advance Request'
    end
  end

  class Event::EMoneyRequest::Base::MailerPresenter < Event::SetNotification::MailerPresenter
    attr_accessor :money_request, :user, :body_val, :subject_val, :button_val

    def initialize(user, money_request, subject, body, button_name)
      self.money_request = money_request
      self.user = user
      self.body_val = body
      self.subject_val = subject
      self.button_val = button_name
    end

    def validate
      self.user.present? and self.money_request.present?
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

    def button_name
      self.button_val
    end

  end

end