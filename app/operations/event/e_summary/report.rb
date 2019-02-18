class Event::ESummary::Reports < Event::SetNotifier
  attr_accessor :users

  def pre_validate
    if params[:user].blank?
      add_message :error, 'User not found'
      return
    end
    if params[:summary].blank?
      add_message :error, 'User not found'
      return
    end
  end

  def action_name
    'Summary'
  end

  def init
  end

  def validate

  end

  def event_id
    NotifierType.id_for(:admin_summary)
  end

  def affected_users
    [params[:user]]
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    SummaryMailer.delay.send_admin_mail(Event::ESummary::Reports::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
    "Finly Summary for #{DateUtils.date_formatted(Date.today)}"
  end

  def mailer_body(user)
    "Please find your Finly Summary Report"
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:action_name] = action_name
  end

  class Event::ESummary::Reports::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :summary, :user, :body_val, :subject_val, :button_val, :action_name, :company

    def init
      self.summary = params[:summary]
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.action_name = params[:action_name]
      self.company = user.company
    end

    def validate
      self.user.present?
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

  end

end
