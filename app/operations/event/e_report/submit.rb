class Event::EReport::Submit < Event::EReport::Base

  def event_id
    NotifierType.report_submit_id
  end

  def affected_users
    [self.report.user, self.report.controlling_user]
  end

  def notification_affected_users
    [report.controlling_user]
  end

  def send_push_notification(user)
    return if user.id == report.user.id
    message = "#{self.report.user.name} has submitted the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.report_id,
                                             action_type_id: NotificationActionType.submit_id,
                                             action_user_id: report.user_id,
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
    if user.id == report.user.id
      "Report submitted : #{self.report.name}"
    else
      "#{self.report.user.name} has submitted the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.user.id
      "Congratulations, you have successfully submitted the report : #{self.report.name}"
    else
      "#{self.report.user.name} has submitted the report: #{self.report.name} and is currently awaiting your approval."
    end
  end

end
