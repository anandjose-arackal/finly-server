class Event::ETravelRequest::Base < Event::SetNotifier
  attr_accessor :travel_request, :role_id

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:travel_request].blank?
      add_message :error, 'TravelRequest not found'
      return
    end
    unless params[:travel_request].is_a?(::TravelRequest)
      add_message :error, 'Error loading travel request'
    end
  end

  def action_name

  end

  def init
    self.travel_request = params[:travel_request]
    self.role_id = params[:role_id]
  end

  def validate
    unless self.travel_request.present?
      add_message :error, 'Travel request not found'
    end
  end

  def get_token(user)

  end

  def send_mailer(user)
  	return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    TravelRequestMailer.delay.send_mail(Event::ETravelRequest::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    if travel_request.controlling_user_id.present? and
      user.id == travel_request.controlling_user_id and not user.id == travel_request.user.id
      'Review travel request'
    else
      'View travel request'
    end
  end

  def travel_request_view_role(user)
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:role_id] = travel_request_view_role(user)
  end

  def allow_mailer(user, configuration)
    super(user, configuration)
    # Manager needs summarized email at the end of day
    # val and (user.manager_summary_mail_configs&.last&.travel_requests&.blank? or self.travel_request&.user == user)
  end

  def process
    # sending mailers
    users = mailer_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? # or not user.is_a?(User)
        user_event_configuration = load_configuration(user)
        if allow_mailer(user, user_event_configuration) && user.email.present?
          send_mailer(user)
        end
      end
    end

    # sending push notifications
    users = push_notification_affected_users
    if users.present?
      users.each do |user|
        next if user.blank?# or not user.is_a?(User)
        user_event_configuration = load_configuration(user)
        if allow_push_notification(user, user_event_configuration)
          send_push_notification(user)
        end
      end
    end

    # sending notifications
    users = notification_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? # or not user.is_a?(User)
        set_notification(user)
      end
    end
  end

  class Event::ETravelRequest::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :travel_request, :user, :body_val, :subject_val, :button_val, :categories, :expenses, :rejected_expenses, :event_id,
                  :action_name, :comment_body, :expenses_sorted, :role_id, :view_url, :company, :action_url_token, :action_url

    def initialize(user, params)
      self.travel_request = params[:travel_request]
      # self.categories = user.company.categories.active
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.expenses = travel_request.expenses
      self.rejected_expenses = params[:rejected_expenses]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
      # self.expenses_sorted = expenses_category_sorted
      self.role_id = params[:role_id]
      self.view_url = generate_url(role_id).html_safe
      self.company = user.company
      if params[:action_url_token]
        self.action_url_token = params[:action_url_token]
        action_url = generate_action_url(user, role_id)
        self.action_url = action_url.html_safe if action_url.present?
        # self.action_url = generate_action_url(user, role_id).html_safe
      end
    end

    def expenses_category_sorted
      categorized_expenses = []
      self.categories.each do |category|
        item_expenses = self.expenses.with_category(category.id)
        if item_expenses.present?
          item_name = category.name
          item_sum = precision_value item_expenses.with_amount.sum(travel_request.base_currency_code)
          categorized_expenses << {section_name: item_name, expenses: item_expenses, section_total: item_sum}
        end
      end
      categorized_expenses
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
      suffix = URI.escape("{\"view\":" + view + ",\"preview\":true}")
      path = "travel_show/#{travel_request.id}/params="
      url = Constants::BASE_URL + path + suffix
    end

    def generate_action_url(user, role_id)
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

      url = nil
      # ToDo- Email Authorization implementation
      # if travel_request.controlling_user_id == user.id
      # # token = params[:email_authorization]

      #   suffix = URI.escape("{\"view\":" + view + ",\"token\":\"#{self.action_url_token}\"}")
      #   path = "travel_show/#{travel_request.id}/params="
      #   url = Constants::BASE_URL_AUTHORIZER + path + suffix
      # end
      url
    end

    def validate
      self.user.present? and self.travel_request.present?
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
