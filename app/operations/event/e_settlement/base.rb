class Event::ESettlement::Base < Event::SetNotifier
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
    return if user.nil?
    set_presenter_params
    return unless subject.present? and body.present?
    SettlementMailer.delay.send_mail Event::ESettlement::Base::MailerPresenter.new(user, params)
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    'View Payment'
  end

  def set_settlement_params
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:action_name] = action_name
    params[:payment_note] = payment.note
  end

  class Event::ESettlement::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :payment, :user, :body_val, :subject_val, :button_val, :action_name, :payment_note

    def initialize(user, params)
      self.payment = params[:payment]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.action_name = params[:action_name]
      self.payment_note = params[:payment_note]
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