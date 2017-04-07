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

  def action_name

  end

  def init
    self.payment = params[:payment]
  end
  
  def affected_users
    [payment.receiving_user]
  end

  def send_mailer(user)
    return if user.nil?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    SettlementMailer.delay.send_mail Event::ESettlement::Base::MailerPresenter.new(user, params)
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    'View Payment'
  end

  def payment_view_role(user)
    return UserRole.id_for(:employee)
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:action_name] = action_name
    params[:payment_note] = payment.note
    params[:role_id] = payment_view_role(user)
  end

  class Event::ESettlement::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :payment, :user, :body_val, :subject_val, :button_val, :action_name, :payment_note,
                  :role_id, :view_url

    def initialize(user, params)
      self.payment = params[:payment]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.action_name = params[:action_name]
      self.payment_note = params[:payment_note]
      self.role_id = params[:role_id]
      self.view_url = generate_url(role_id).html_safe
    end

    def generate_url(role_id)
      view = ""
      case role_id
        when 3
          view = "\"manager\""
        when 2
          view = "\"finance_manager\""
        when 1
          view = "\"admin\""
        else
          view = "\"personal\""
      end
      suffix = "/params={\"view\":" + view + "}"
      path = "settlements/"
      if view == "\"personal\"" || view.nil?
        path += "#{user.id}"
      end
      url = Constants::BASE_URL + path + suffix
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