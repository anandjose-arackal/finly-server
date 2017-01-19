class Event::EReport::Retract < Event::EReport::Base

  def event_id
    NotifierType.id_for(:report_retract)
  end

  def affected_users
    users = Report::AssociatedUsers.(self.user, report: self.report, user_before: self.report.tracks.last.modified_user)
    users.reject { |r| r == self.user}
  end

  def notification_affected_users
    users = Report::AssociatedUsers.(self.user, report: self.report, user_before: self.report.tracks.last.modified_user)
    users.reject { |r| r == self.user}
  end

  def send_push_notification(user)
    return if user.id == report.controlling_user_id
    message = "#{self.report.user.name} retracted the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    roles = Report::ActionUserRole.(user, {report: report, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_reject),
                                             action_user_id: report.user_id,
                                             object_id: report.id,
                                             object_type: "Report",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first
                                            )
    notification.save
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
