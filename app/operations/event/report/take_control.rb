class Event::Report::TakeControl < Event::Report::Base

  def event_id
    Event.report_take_control_id
  end

  def affected_users
    [self.report.controlling_user, self.report.controlling_for_user]
  end

  def send_push_notification(user)
    return if user.id == report.controlling_user_id
    message = "#{self.report.controlling_user.name} has taken control of the report : #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == report.controlling_user_id

    else
      "#{self.report.controlling_user.name} has has taken control of the report"
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user_id

    else
      "#{self.report.controlling_user.name} has has taken control of the report which was awaiting your review.<br/><br/>Report: \"#{self.report.name}\""
    end
  end

end