class Event::Report::Unapprove < Event::Report::Base

  def event_id
    Event.report_unapprove_id
  end

  def affected_users
    prev_user = self.report.tracks[-2].user rescue nil
    [self.report.controlling_user, prev_user]
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if report.controlling_user.id == user.id
      "Report unapproved : #{self.report.name}"
    else
      "#{self.report.controlling_user.name} has unapproved the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if report.controlling_user.id == user.id
      "You have successfully unapproved the report : #{self.report.name}"
    else
      "#{self.report.controlling_user.name} has unapproved the report: #{self.report.name}"
    end
  end

end