class Event::EMoneyRequest::Unapprove < Event::EMoneyRequest::Base

  def event_id
    NotifierType.id_for(:money_request_unapprove)
  end

  def affected_users
    [self.money_request.controlling_user, self.money_request.tracks.last.modified_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.controlling_user_id
    message = "#{self.money_request.controlling_user.name} unapproved the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)
    if money_request.controlling_user_id == user.id
      view_role_id = money_request.controlling_user_role_id
    else
      view_role_id = money_request.tracks.last.modified_user_role_id
    end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:advance_request),
                                             action_type_id: NotificationActionType.id_for(:notify_unapprove),
                                             action_user_id: self.user.id,
                                             object_id: money_request.id,
                                             object_type: "Advance Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Advance Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id
    )
    notification.save
  end

  def mailer_subject(user)
    if money_request.controlling_user.id == user.id
      "Advance Request unapproved : #{self.money_request.name}"
    else
      "#{self.money_request.controlling_user.name} has unapproved the Advance Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if money_request.controlling_user.id == user.id
      "You have successfully unapproved the Advance Request : #{self.money_request.name}"
    else
      "#{self.money_request.controlling_user.name} has unapproved the Advance Request: #{self.money_request.name}"
    end
  end

end