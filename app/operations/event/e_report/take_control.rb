class Event::EReport::TakeControl < Event::EReport::Base

  def event_id
    NotifierType.id_for(:report_take_control)
  end

  def action_name
    "Report Taken Control of"
  end

  def affected_users
    # [self.report.controlling_user, self.report.controlling_for_user]
    [self.report.controlling_user, self.report.controlling_for_user]
  end

  def notification_affected_users
    [report.controlling_for_user]
  end

  def send_push_notification(user)
    return unless user.id == report.controlling_for_user_id
    message = "#{self.report.controlling_user.name} has taken control of the report : #{self.report.name}"
    view = UserRole.name_for(self.report.controlling_for_user_role_id)
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    if report.controlling_for_user_id == user.id
      view_role_id = report.controlling_for_user_role_id
    else
      view_role_id = nil
    end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
                                             action_user_id: (report.tracks.last.action_user.id rescue nil),
                                             object_id: report.id,
                                             object_type: "Report",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id,
                                             application: RequestStore.store[:current_app]
                                            )
    notification.save
  end

  def mailer_subject(user)
    if user.id == report.controlling_user_id
      "You have taken control of the report: #{self.report.name}"
    else
      "#{self.report.controlling_user.name} has taken control of the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user_id
      "You have taken control of the report.<br/><br/>Report: \"#{self.report.name}\""
    else
      "#{self.report.controlling_user.name} has taken control of the report which was awaiting your review.<br/><br/>Report: \"#{self.report.name}\""
    end
  end

  def report_view_role(user)
    roles = Reports::ActionUserRole.(user, {report: report, user_id: user.id})
    roles.first
  end

end
