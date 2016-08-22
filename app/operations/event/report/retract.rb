class Event::Report::Retract < Event::Report::Base

  def event_id
    Event.report_approve_id
  end

  def affected_users
    tracks = self.report.tracks
    manager = tracks[-2].user rescue nil
    [self.user, manager]
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
      "Report retracted : #{self.report.name}"
    else
      "#{user.name} has retracted the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.user.id
      "You have successfully retracted the report : #{self.report.name}"
    else
      "#{user.name} has retracted the report '#{self.report.name}'."
    end
  end

end
