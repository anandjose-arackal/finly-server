class Event::EReport::Retract < Event::EReport::Base

  attr_accessor :roles

  def event_id
    NotifierType.id_for(:report_retract)
  end

  def action_name
    "Report Retracted"
  end

  def affected_users
    users = Reports::AssociatedUsers.(self.user, report: self.report, user_before: self.report.tracks.last.modified_user)
    users.reject { |r| r == self.user}
  end

  def notification_affected_users
    users = Reports::AssociatedUsers.(self.user, report: self.report, user_before: self.report.tracks.last.modified_user)
    users.reject { |r| r == self.user}
  end

  def send_push_notification(user)
    last_track = self.report.tracks.last
    return unless user.id == last_track&.modified_user&.id
    message = "#{self.report.user.name} retracted the report: #{self.report.name}"
    view = UserRole.name_for(last_track.modified_user_role_id)
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    self.roles = Reports::ActionUserRole.(user, {report: report, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_retract),
                                             action_user_id: report.user_id,
                                             object_id: report.id,
                                             object_type: "Report",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first,
                                             application: RequestStore.store[:current_app])
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

  def report_view_role(user)
    self.roles = Reports::ActionUserRole.(user, {report: report, user_id: user.id})
    return roles.first
  end

end
