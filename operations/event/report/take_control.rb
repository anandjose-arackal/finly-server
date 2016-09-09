class Event::Report::TakeControl < Event::Report::Base

  def event_id
    Event.report_take_control_id
  end

  def affected_users
    self.report.controlling_for_user
  end

  def mailer_subject(user)
    "#{self.report.controlling_user.name} has has taken control of the report"
  end

  def mailer_body(user)
    "#{self.report.controlling_user.name} has has taken control of the report which was awaiting your review.<br/><br/>Report: \"#{self.report.name}\""
  end

end