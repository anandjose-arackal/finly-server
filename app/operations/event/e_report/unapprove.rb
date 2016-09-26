class Event::EReport::Unapprove < Event::EReport::Base

  def event_id
    Event.report_unapprove_id
  end

  def affected_users
    prev_user = params[:from_user]
    users = [self.report.controlling_user]
    users << prev_user if prev_user.present?
    users
  end

  def send_push_notification(user)
    return if user.id == report.controlling_user_id
    message = "#{self.report.controlling_user.name} unapproved the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
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