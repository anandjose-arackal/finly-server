class Event::Report::Comment < Event::Report::Base

  def event_id
    Event.report_approve_id
  end

  def affected_users
    users = self.report.associated_users
    users.delete(self.user)
    users
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def set_notification(user)

  end

  def mailer_method(user)
    :comment
  end

  def mailer_subject(user)
    "#{user.name} has commented on the report: #{self.report.name}"
  end

  def mailer_body(user)
    comment = report.comments.last.content rescue nil
    "#{user.name} has comment on the report '#{self.report.name}'<br/><br/>'#{comment}'"
  end

  def mailer_button_name
    'View Report'
  end

end
