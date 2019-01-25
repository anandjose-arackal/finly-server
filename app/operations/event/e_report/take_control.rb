class Event::EReport::TakeControl < Event::EReport::Base

  def event_id
    NotifierType.id_for(:report_take_control)
  end

  def action_name
    "Report Taken Control of"
  end

  def affected_users
    # [self.report.controlling_user, self.report.controlling_for_user]
    # [self.report.controlling_user, self.report.controlling_for_user]
    self.report.affected_users(:take_control)
  end

  def notification_affected_users
    # [report.controlling_for_user]
    self.report.notification_affected_users(:take_control)
  end

  def send_push_notification(user)
    # return unless user.id == report.controlling_for_user_id
    return unless self.report.document_level_reviewer_mappings.with_level_id(report.controlling_level_id).pluck(:reviewer_id).include?(user.id)
    last_trail = self.report.trails.last
    message = "#{last_trail.action_user.name} has taken control of the report : #{self.report.name}"
    # view = UserRole.name_for(self.report.controlling_for_user_role_id)
    view = 'manager'
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    if report.notification_affected_users(:take_control).include? user
      view_role_id = UserRole.id_for(:manager)
    else
      view_role_id = nil
    end
    last_trail = report.trails.last
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
                                             action_user_id: (last_trail.action_user_id rescue nil),
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
    if user.id == report.trails.last.action_user_id
    # if user.id == report.controlling_user_id
      "You have taken control of the report: #{self.report.name}"
    else
      "#{self.report.trails.last.action_user.name} has taken control of the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.trails.last.action_user_id
      "You have taken control of the report.<br/><br/>Report: \"#{self.report.name}\""
    else
      "#{self.report.trails.last.action_user.name} has taken control of the report which was awaiting your review.<br/><br/>Report: \"#{self.report.name}\""
    end
  end

  def report_view_role(user)
    # roles = Reports::ActionUserRole.(user, {report: report, user_id: user.id})
    # roles.first
    report.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end
