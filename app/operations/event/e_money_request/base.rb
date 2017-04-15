class Event::EMoneyRequest::Base < Event::SetNotifier
  attr_accessor :money_request

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
    end
    if params.blank? or params[:money_request].blank?
      add_message :error, 'Money Request not found'
    end
    unless params[:money_request].is_a?(::MoneyRequest)
      add_message :error, 'Error loading Money Request'
    end
  end

  def action_name

  end

  def init
    self.money_request = params[:money_request]
  end

  def validate
    unless self.money_request.present?
      add_message :error, 'Money Request not found'
    end
  end

  def send_mailer(user)
    return if user.nil?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    MoneyRequestMailer.delay.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    if money_request.controlling_user_id.present? and
        user.id == money_request.controlling_user_id and not user.id == money_request.user.id
      'Review Money Request'
    else
      'View Money Request'
    end
  end

  def money_request_view_role(user)

  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:role_id] = money_request_view_role(user)
  end

  class Event::EMoneyRequest::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :money_request, :user, :body_val, :subject_val, :button_val, :event_id,
                  :action_name, :comment_body, :role_id, :view_url, :company

    def initialize(user, params)
      self.money_request = params[:money_request]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
      self.role_id = params[:role_id]
      self.view_url = generate_url(role_id).html_safe
      self.company = user.company
    end

    def generate_url(role_id)
      view = ""
      case role_id
        when 3
          view = 'manager'
        when 2
          view = 'finance_manager'
        when 1
          view = 'admin'
        else
          view = 'personal'
      end
      suffix = '/params={"view":"' + view + '","preview":true}'
      path = 'requests/' + money_request.id.to_s
      url = Constants::BASE_URL + path + suffix
      return url
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
