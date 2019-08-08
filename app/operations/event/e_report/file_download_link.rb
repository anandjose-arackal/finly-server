class Event::EReport::FileDownloadLink < Event::EReport::Base
  attr_accessor :download_url

  def action_name
    "Download Report Excel - "
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.download_url = params[:download_url]
  end

  def validate
  end

  def send_mailer(user)
  set_presenter_params(user)
  return unless params[:subject].present? and params[:body].present? and user.email.present?
  ReportMailer.delay.send_export_mail(Event::EReport::FileDownloadLink::MailerPresenter.new(user, params))
  end

  def set_presenter_params(user)
    params[:download_url] = self.download_url
    params[:subject] = mailer_subject(user)
    params[:body] = mailer_body(user)
    params[:action_name] = action_name
  end

  def event_id
    NotifierType.id_for(:bulk_export)
  end

  def affected_users
    [user]
  end

  def process
    users = mailer_affected_users
    if users.present?
      users.each do |user|
        send_mailer(user)
      end
    end
  end

  def set_notification(user)
  end

  def mailer_subject(user)
    "Download report data - #{Time.now.in_time_zone("Chennai").strftime('%-d/%-m/%y: %H:%M %Z')}"
  end

  def mailer_body(user)
    "Download report data requested on #{Time.now.in_time_zone("Chennai").strftime('%-d/%-m/%y: %H:%M %Z')}"
  end

  class Event::EReport::FileDownloadLink::MailerPresenter < Event::SetNotifier::MailerPresenter

    attr_accessor :body_val, :subject_val, :event_id, :action_name, :company, :download_url

    def initialize(user, params)
      self.body_val = params[:body]
      self.subject_val = params[:subject]
      self.action_name = params[:action_name]
      self.user = user
      self.company = user.company
      self.download_url = params[:download_url]
    end

    def subject
      self.subject_val
    end

    def body
      self.body_val
    end

    def to
      self.user.email
    end
  end




end