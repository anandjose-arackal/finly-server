class Event::ESummary::Report < Event::SetNotifier
  attr_accessor :users

  def pre_validate
  end

  def action_name
    'Summary'
  end

  def init
    fetch_users
  end

  def validate
    unless users.present?
      add_message :error, 'No user has requested for summary at this time'
    end
  end

  def event_id
    NotifierType.id_for(:funds_summary)
  end

  def affected_users
    self.users
  end

  def send_mailer(user)
    return if user.blank?
    set_presenter_params(user)
    return unless params[:subject].present? and params[:body].present?
    CardTransactionMailer.delay.send_mail(Event::ECard::ETransaction::Base::MailerPresenter.new(user, params))
  end

  def mailer_subject(user)
    "Finly Summary for #{DateUtils.date_formatted(Date.today)}"
  end

  def mailer_body(user)
    "Please find your Finly Summary for #{DateUtils.date_formatted(Date.today)}"
  end

  def summary(user)
    s = []
    if user.company.d_code_enabled?
      if user.company_admin?
        # s << {name: 'Company Credits Opening Balance', value: }
      end
    end
  end

  def set_presenter_params(user)
    params[:subject] = self.mailer_subject(user)
    params[:body] = self.mailer_body(user)
    params[:button_name] = self.mailer_button_name(user)
    params[:action_name] = action_name
    params[:summary] = self.summary(user)
  end

  class Event::ESummary::Report::MailerPresenter < Event::SetNotifier::MailerPresenter
    attr_accessor :summary, :user, :body_val, :subject_val, :button_val, :action_name, :company

    def init(user, params)
      self.summary = params[:summary]
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.action_name = params[:action_name]
      self.company = user.company
    end

    def validate
      self.user.present? and self.transaction.present?
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

  protected
  # slot - times with 30minute difference
  # Identify the slot current time belongs to.
  # Ex: if current time is 5:40, then the slot is 5:30 slab. If the time is 05:25, then the slot is 05:00
  def fetch_time_slot(datetime)
    time_slot = datetime.strftime('%H')
    if datetime.minute < 30
      time_slot += ':00'
    else
      time_slot += ':30'
    end
    time_slot
  end

  def fetch_users
    datetime = DateTime.today
    day_of_month = datetime.day
    day_of_week = datetime.strftime("%A")
    time_slot = fetch_time_slot datetime
    configurations = SummaryMailConfiguration.configurations_for day_of_month, day_of_week, time_slot
    user_ids = configurations.pluck(:user_id)
    self.users = User.with_id(user_ids)
  end

end
