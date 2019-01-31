class Event::EReport::Submit < Event::EReport::Base

  def event_id
    NotifierType.id_for(:report_submit)
  end

  def action_name
    'Report Submitted'
  end

  def affected_users
    # [self.report.user, self.report.reload.controlling_user]
    self.report.affected_users(:submit)
  end

  def get_token(user)
    email_authorization = params[:email_authorization].where(user_id: user.id)&.last
    email_authorization&.token
  end

  def notification_affected_users
    # [report.controlling_user]
    self.report.notification_affected_users(:submit)
  end

  def send_push_notification(user)
    return if user.id == report.user.id
    message = "#{self.report.user.name} has submitted the report: #{self.report.name}"
    view = 'manager'
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    # view_role_id = UserRole.id_for(:manager)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: report.user_id,
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
    if user.id == report.user_id
      "Report submitted : #{self.report.name}"
    else
      "#{self.report.user.name} has submitted the report: #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.user_id
      "Congratulations, you have successfully submitted the report : #{self.report.name}"
    else
      "#{self.report.user.name} has submitted the report: #{self.report.name} and is currently awaiting your approval."
    end
  end

  def report_view_role(user)
    # if user.id == report.user_id
    #   return nil
    # elsif report.get_reviewers.include? user
    #   return UserRole.id_for(:manager)
    # end
    report.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end
end
