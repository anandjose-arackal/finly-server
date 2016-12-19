class Event::EMoneyRequest::Submit < Event::EMoneyRequest::Base

  def event_id
    NotifierType.money_request_submit_id
  end

  def affected_users
    [self.money_request.user, self.money_request.controlling_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.user.id
    message = "#{self.money_request.user.name} has submitted the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user, role = nil)
    notification = user.notifications.create(notification_type_id: NotificationType.advance_request_id,
                                             action_type_id: NotificationActionType.notify_submit_id,
                                             action_user_id: money_request.user_id,
                                             object_id: money_request.id,
                                             object_type: "Advance Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Advance Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: money_request.controlling_user_role_id
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == money_request.user.id
      "Advance Request submitted : #{self.money_request.name}"
    else
      "#{self.money_request.user.name} has submitted the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.user.id
      "Congratulations, you have successfully submitted the Advance Request: #{self.money_request.name}"
    else
      "#{self.money_request.user.name} has submitted the Advance Request: #{self.money_request.name} and is currently awaiting your approval"
    end
  end

end
