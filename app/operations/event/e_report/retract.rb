class Event::EReport::Retract < Event::EReport::Base

  def event_id
    Event.report_retract_id
  end

  def affected_users
    self.report.associated_users self.report.tracks.last.modified_user
  end

  def send_push_notification(user)
    return if user.id == report.controlling_user_id
    message = "#{self.report.user.name} retracted the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == report.user.id
      "Report retracted : #{self.report.name}"
    else
      "#{report.user.name} has retracted the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.user.id
      "You have successfully retracted the report : #{self.report.name}"
    else
      "#{report.user.name} has retracted the report '#{self.report.name}'."
    end
  end

end
