class Event::EReport::Unapprove < Event::EReport::Base

  def event_id
    NotifierType.id_for(:report_unapprove)
  end

  def action_name
    "Report Unapproved"
  end

  def affected_users
    # [self.report.controlling_user, self.report.tracks.last.modified_user]
    self.report.affected_users(:unapprove)
  end

  def send_push_notification(user)
    return if self.report.get_reviewers&.include? user
    message = "#{self.report.trails.last.action_user_id.name} unapproved the report: #{self.report.name}"
    # view = UserRole.name_for(self.report.tracks.last.modified_user_role_id)
    view = 'manager'
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    if report.get_reviewers.include? user
      view_role_id = UserRole.id_for(:manager)
    else
      # view_role_id = report.tracks.last.modified_user_role_id
      view_role_id = UserRole.id_for(:manager)
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
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if report.get_reviewers.include? user
      "Report unapproved : #{self.report.name}"
    else
      "#{self.report.trails.last.action_user.name} has unapproved the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if report.get_reviewers.include? user
      "You have successfully unapproved the report : #{self.report.name}"
    else
      "#{self.report.trails.last.action_user.name} has unapproved the report: #{self.report.name}"
    end
  end

  def report_view_role(user)
    # if report.controlling_user_id == user.id
    #   return report.controlling_user_role_id
    # else
    #   return report.tracks.last.modified_user_role_id
    # end
    report.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end
