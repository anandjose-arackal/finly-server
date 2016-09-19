class Event::Settlement::Base < Event::SetNotification
  attr_accessor :payment

  def pre_validate
    unless user.present?
      messages[:error] << 'User not found'
    end
    if params.blank? or params[:payment].blank?
      messages[:error] << 'Payment not found'
    end
    unless params[:payment].is_a?(Payment)
      messages[:error] << 'Error loading payment'
    end
  end

  def init
    self.payment = params[:payment]
  end
  
  def affected_users
    [payment.receiving_user]
  end

  def send_mailer(user)
    subject = self.mailer_subject(user)
    body = self.mailer_body(user)
    button_name = self.mailer_button_name(user)
    return unless subject.present? and body.present?
    SettlementMailer.send_mail Event::Settlement::Base::MailerPresenter.new(user, payment, subject, body, button_name)
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
  end

  class Event::Settlement::Base::MailerPresenter < Event::SetNotification::MailerPresenter
    attr_accessor :payment, :user, :body_val, :subject_val, :button_val

    def initialize(user, payment, subject, body, button_name)
      self.payment = payment
      self.user = user
      self.body_val = body
      self.subject_val = subject
      self.button_val = button_name
    end

    def validate
      self.user.present? and self.payment.present?
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