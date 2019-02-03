class Event::EPurchaseOrder::Base < Event::SetNotifier
  attr_accessor :purchase_order, :controlling_users, :workflow_output

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:purchase_order].blank?
      add_message :error, 'Purchase Order not found'
      return
    end
    unless params[:purchase_order].is_a?(::PurchaseOrder)
      add_message :error, 'Error loading purchase order'
    end
  end

  def action_name

  end

  def init
    self.purchase_order = params[:purchase_order]
    self.workflow_output = params[:workflow_output]
    self.controlling_users = []
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
    end
  end

  # def get_token(user)
  #
  # end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    ProcurementMailer.delay.send_purchase_order_mail(Event::EPurchaseOrder::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    # if report.controlling_user_id.present? and
    #     user.id == purchase_order.controlling_user_id and not user.id == report.user.id
    #   'Review Purchase Order'
    # else
    'View Purchase Order'
    # end
  end

  # def report_view_role(user)
  # end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
    # params[:role_id] = report_view_role(user)
    # if params[:email_authorization]
    #   params[:action_url_token] = get_token(user)
    # end
  end

  def allow_mailer(user, configuration)
    # val = super(user, configuration)
    # val and (user.manager_summary_mail_configs.reports.blank? or report.user == user)
    true
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
    # users = push_notification_affected_users
    # if users.present?
    #   users.each do |user|
    #     next if user.blank?# or not user.is_a?(User)
    #     user_event_configuration = load_configuration(user)
    #     if allow_push_notification(user, user_event_configuration)
    #       send_push_notification(user)
    #     end
    #   end
    # end

    # sending notifications
    users = notification_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? # or not user.is_a?(User)
        set_notification(user)
      end
    end
  end

  class Event::EPurchaseOrder::Base::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :purchase_order, :user, :body_val, :subject_val, :button_val, :event_id,
                  :action_name, :comment_body, :view_url, :company, :action_url_token, :action_url

    def initialize(user, params)
      self.purchase_order = params[:purchase_order]
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.button_val = params[:button_name]
      self.event_id = params[:event_id]
      self.action_name = params[:action_name]
      self.comment_body = params[:comment_body]
      self.view_url = generate_url.html_safe
      self.company = user.company
      # if params[:action_url_token]
      #   self.action_url_token = params[:action_url_token]
      #   action_url = generate_action_url(user, role_id)
      #   self.action_url = action_url.html_safe if action_url.present?
      #   # self.action_url = generate_action_url(user, role_id).html_safe
      # end
    end

    def generate_url
      suffix = URI.escape("{\"show\":\"purchase_order\"}")
      # path = "reports/#{report.id}"
      path = "procurements/#{purchase_order.procurement.id}/params="
      url = Constants::BASE_URL_VP + path + suffix
    end

    # def generate_action_url(user, role_id)
    #   view = ""
    #   case role_id
    #     when 3
    #       view = "\"manager\""
    #     when 2
    #       view = "\"finance_manager\""
    #     when 1
    #       view = "\"admin\""
    #     else
    #       view = "\"personal\""
    #   end
    #
    #   url = nil
    #   if report.controlling_user_id == user.id
    #     # token = params[:email_authorization]
    #
    #     # suffix = "/params={\"view\":" + view + ",\"token\":\"#{self.action_url_token}\"}"
    #     path = "report/#{report.id}"
    #     path = "payments#procurements/#{purchase_order.procurement.id}"
    #
    #     url = Constants::BASE_URL_AUTHORIZER + path + suffix
    #   end
    #   url
    # end

    def validate
      self.user.present? and self.purchase_order.present?
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
