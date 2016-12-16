class Event::EReport::TakeControl < Event::EReport::Base

  def event_id
    NotifierType.report_take_control_id
  end

  def affected_users
    # [self.report.controlling_user, self.report.controlling_for_user]
    [self.report.controlling_user, self.report.controlling_for_user]
  end

  def notification_affected_users
    [report.user, report.controlling_for_user]
  end

  def send_push_notification(user)
    return if user.id == report.controlling_user_id
    message = "#{self.report.controlling_user.name} has taken control of the report : #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.report_id,
                                             action_type_id: NotificationActionType.notify_take_control_id,
                                             action_user_id: (report.tracks.last.action_user.id rescue nil),
                                             object_id: report.id,
                                             object_type: "Report",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == report.controlling_user_id
      "You have taken control of the report: #{self.report.name}"
    else
      "#{self.report.controlling_user.name} has has taken control of the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user_id
      "You have taken control of the report.<br/><br/>Report: \"#{self.report.name}\""
    else
      "#{self.report.controlling_user.name} has has taken control of the report which was awaiting your review.<br/><br/>Report: \"#{self.report.name}\""
    end
  end

end
