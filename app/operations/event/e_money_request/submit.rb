class Event::EMoneyRequest::Submit < Event::EMoneyRequest::Base

  def event_id
    NotifierType.id_for(:money_request_submit)
  end

  def action_name
    "Money Request Submitted"
  end

  def affected_users
    [self.money_request.user, self.money_request.controlling_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.user_id
    message = "#{self.money_request.user.name} has submitted the Money Request: #{self.money_request.name}"
    view = UserRole.name_for(money_request.controlling_user_role_id)
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
  end

  def notification_affected_users
    [self.money_request.controlling_user]
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:money_request),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: money_request.user_id,
                                             object_id: money_request.id,
                                             object_type: "Money Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Money Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: money_request.controlling_user_role_id)
    notification.save
  end

  def mailer_subject(user)
    if user.id == money_request.user.id
      "Money Request submitted : #{self.money_request.name}"
    else
      "#{self.money_request.user.name} has submitted the Money Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.user.id
      "Congratulations, you have successfully submitted the Money Request: #{self.money_request.name}"
    else
      "#{self.money_request.user.name} has submitted the Money Request: #{self.money_request.name} and is currently awaiting your approval"
    end
  end

  def money_request_view_role(user)
    roles = MoneyRequest::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    roles.first
  end

end
