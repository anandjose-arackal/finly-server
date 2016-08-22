class Event::Report::Reject < Event::Report::Base

  def event_id
    Event.report_approve_id
  end

  def affected_users
    [self.report.tracks.last.user, self.report.controlling_user]
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def set_notification(user)

  end

  def mailer_method(user)
    :reject
  end

  def mailer_subject(user)
    if user.id == report.controlling_user.id
      "#{user.name} has rejected the report: #{self.report.name}"
    else
      "Report rejected : #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user.id
      "#{user.name} has rejected the report: '#{self.report.name}'"
    else
      "You have rejected the report : #{self.report.name}"
    end
  end

end
