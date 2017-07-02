class Event::EReport::Base < Event::SetNotifier
  attr_accessor :report, :rejected_expenses

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:report].blank?
      add_message :error, 'Report not found'
      return
    end
    unless params[:report].is_a?(::Report)
      add_message :error, 'Error loading report'
    end
  end

  def action_name

  end

  def init
    self.report = params[:report]
  end

  def validate
    unless self.report.present?
      add_message :error, 'Report not found'
    end
  end

  def get_token(user)

  end

  def send_mailer(user)
  	return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    ReportMailer.delay.send_mail(Event::EReport::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    if report.controlling_user_id.present? and
      user.id == report.controlling_user_id and not user.id == report.user.id
      'Review Report'
    else
      'View Report'
    end
  end

  def report_view_role(user)

  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    params[:role_id] = report_view_role(user)
    if params[:email_authorization]
      params[:action_url_token] = get_token(user)
    end
  end

  class Event::EReport::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :report, :user, :body_val, :subject_val, :button_val, :categories, :expenses, :rejected_expenses, :event_id,
                  :action_name, :comment_body, :expenses_sorted, :role_id, :view_url, :company, :action_url_token, :action_url

    def initialize(user, params)
      self.report = params[:report]
      self.categories = user.company.categories.active
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.expenses = report.expenses
      self.rejected_expenses = params[:rejected_expenses]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
      self.expenses_sorted = expenses_category_sorted
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
          item_sum = precision_value item_expenses.with_amount.sum(:value)
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
      suffix = "/params={\"view\":" + view + ",\"preview\":true}"
      path = "reports/#{report.id}"
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
      if report.controlling_user_id == user.id
      # token = params[:email_authorization]

        suffix = "/params={\"view\":" + view + ",\"token\":\"#{self.action_url_token}\"}"
        path = "report/#{report.id}"
        url = Constants::BASE_URL_AUTHORIZER + path + suffix
      end
      url
    end

    def validate
      self.user.present? and self.report.present?
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
