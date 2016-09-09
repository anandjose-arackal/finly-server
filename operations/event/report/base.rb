class Event::Report::Base < Event::SetNotification
  attr_accessor :report

  def pre_validate
    unless user.present?
      errors << 'User not found'
    end
    if params.blank? or params[:report].blank?
      errors << 'Report not found'
    end
    unless params[:report].is_a?(Report)
      errors << 'Error loading report'
    end
  end

  def init
    self.report = params[:report]
  end

  def send_mailer(user)
    subject = self.mailer_subject(user)
    body = self.mailer_body(user)
    button_name = self.mailer_button_name(user)
    return unless subject.present? and method.present?
    ReportMailer.send_mail(Event::Report::Base::MailerPresenter.new(user, report, subject, body, button_name))
  end

  def mailer_subject(user)
  end

  def mailer_body(user)
  end

  def mailer_button_name(user)
    if user.id == report.controlling_user.id and not user.id == report.user.id
      'Review Report'
    else
      'View Report'
    end
  end

  class Event::Report::Base::MailerPresenter < Event::SetNotification::MailerPresenter
    attr_accessor :report, :user, :body_val, :subject_val, :button_val

    def initialize(user, report, subject, body, button_name)
      self.report = report
      self.user = user
      self.body_val = body
      self.subject_val = subject
      self.button_val = button_name
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