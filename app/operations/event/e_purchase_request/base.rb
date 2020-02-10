class Event::EPurchaseRequest::Base < Event::SetNotifier
  attr_accessor :purchase_request, :workflow_output

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:purchase_request].blank?
      add_message :error, 'Purchase Request not found'
      return
    end
    unless params[:purchase_request].is_a?(::PurchaseRequest)
      add_message :error, 'Error loading purchase order'
    end
  end

  def init
    self.purchase_request = params[:purchase_request]
    self.workflow_output = params[:workflow_output]
  end

  def validate
    unless self.purchase_request.present?
      add_message :error, 'Purchase Request not found'
    end
  end

  def action_name

  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    ProcurementMailer.delay.send_purchase_request_mail(Event::EPurchaseRequest::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
  end


  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:event_id] = event_id
    params[:action_name] = action_name
  end

  def allow_mailer(user, configuration)
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

    # sending notifications
    users = notification_affected_users
    if users.present?
      users.each do |user|
        next if user.blank? # or not user.is_a?(User)
        set_notification(user)
      end
    end
  end

  class Event::EPurchaseRequest::Base::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :user, :body_val, :subject_val, :company, :purchase_request, :action_name, :action_url

    def initialize(user, params)
      self.user = user
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.company = user.company
      self.purchase_request = params[:purchase_request]
      self.action_name = params[:action_name]
      self.action_url = params[:action_url]
    end

    def to
      user.email
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end
  end

end
