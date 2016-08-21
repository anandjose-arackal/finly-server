class Event::Report::Submit < Event::Report::Base

  def event_id
    Event.report_submit_id
  end

  def affected_users
    [self.report.user, self.report.controlling_user]
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def send_mailer(user)
    ReportMailer.submit(self.report, user)
  end

  def set_notification(user)

  end
end
