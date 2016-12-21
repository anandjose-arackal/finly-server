class Event::EMoneyRequest::Retract < Event::EMoneyRequest::Base

  def event_id
    NotifierType.money_request_retract_id
  end

  def affected_users
    users = MoneyRequest::AssociatedUsers.(self.user, money_request: self.money_request, user_before: self.money_request.tracks.last.modified_user)
    users.reject { |r| r == self.user}
  end

  def send_push_notification(user)
    return if user.id == money_request.controlling_user_id
    message = "#{self.money_request.user.name} retracted the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.advance_request_id,
                                             action_type_id: NotificationActionType.notify_retract_id,
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
      "Advance Request retracted : #{self.money_request.name}"
    else
      "#{money_request.user.name} has retracted the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.user.id
      "You have successfully retracted the Advance Request : #{self.money_request.name}"
    else
      "#{money_request.user.name} has retracted the Advance Request '#{self.money_request.name}'."
    end
  end

end
