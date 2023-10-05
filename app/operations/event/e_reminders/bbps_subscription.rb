class Event::EReminders::BbpsSubscription < BaseOperation
  
  def action_name
    "Reminder Email for #{params[:utility_operator_or_vendor]} subscriptions"
  end

  def mailer_body(user = nil)
    "This is to send reminder email to the users who have dues on utility subscriptions"
  end

  def mailer_subject(user = nil)
    "Reminder - Payment for #{params[:utility_operator_or_vendor]} Bill Due"
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def process
    send_mailer(user)
  end

  def send_mailer(user)
    return if user.blank?
    
    set_presenter_params
    return unless params[:subject].present? && params[:body].present?
    
    params[:action_name] = action_name
    
    BbpsReminderMailer.delay.send_bbps_reminder_mail(
      # Event::EReminders::BbpsSubscription::MailerPresenter.new(user, params)
      user&.id, params
    )
  end

  def set_presenter_params(user = nil)
    params[:subject] = self.mailer_subject
    params[:body] = self.mailer_body
  end  

  # presenter class for the reminder emails
  class MailerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :user, :company, :body, :subject, :action_name, :payload

    def initialize(user, params)
      self.user = user
      self.company = user.company
      self.body = params[:body]
      self.subject = params[:subject]
      self.action_name = params[:action_name]
      self.payload = params.except(:body, :subject, :action_name)
    end

    def to
      user.email
    end
  end  
end
