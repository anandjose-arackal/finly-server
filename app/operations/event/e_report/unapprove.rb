class Event::EReport::Unapprove < Event::EReport::Base

  def event_id
    NotifierType.id_for(:report_unapprove)
  end

  def action_name
    "Report Unapproved"
  end

  def affected_users
    [self.report.controlling_user, self.report.tracks.last.modified_user]
  end

  def send_push_notification(user)
    return if user.id == report.controlling_user_id
    message = "#{self.report.controlling_user.name} unapproved the report: #{self.report.name}"
    view = UserRole.name_for(self.report.tracks.last.modified_user_role_id)
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    if report.controlling_user_id == user.id
      view_role_id = report.controlling_user_role_id
    else
      view_role_id = report.tracks.last.modified_user_role_id
    end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_unapprove),
                                             action_user_id: self.user.id,
                                             object_id: report.id,
                                             object_type: "Report",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id
    )
    notification.save
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
