class Event::Report::Approve < Event::Report::Base

  def event_id
    Event.report_approve_id
  end

  def affected_users
    [self.report.tracks.last.user, self.report.controlling_user] if report.processing?
    [self.report.controlling_user, self.report.user] if report.approved? or report.closed?
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def set_notification(user)

  end

  def mailer_method(user)
    :approve
  end

  def mailer_subject(user)
    if user.id == report.controlling_user.id
      "Report approved : #{self.report.name}"
    else
      "#{user.name} has approved the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user.id
      "You have successfully approved the report : #{self.report.name}"
    else
      "#{user.name} has approved the report '#{self.report.name}' and is currently waiting for your approval"
    end
  end

end
