class Event::EMoneyRequest::TakeControl < Event::EMoneyRequest::Base

  def event_id
    NotifierType.id_for(:money_request_take_control)
  end

  def affected_users
    [self.money_request.controlling_for_user]
  end

  def notification_affected_users
    [report.controlling_for_user]
  end

  def send_push_notification(user)
    return if user.id == money_request.controlling_user_id
    message = "#{self.money_request.controlling_user.name} has taken control of the Money Request : #{self.money_request.name}"
    view = UserRole.name_for(self.money_request.controlling_for_user_role_id)
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
  end

  def notification_affected_users
    [self.money_request.controlling_for_user]
  end

  def set_notification(user)
    # debugger
    if money_request.controlling_for_user_id == user.id
      view_role_id = money_request.controlling_for_user_role_id
    else
      view_role_id = nil
    end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:money_request),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
                                             action_user_id: (money_request.tracks.last.action_user.id rescue nil),
                                             object_id: money_request.id,
                                             object_type: "Money Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Money Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == money_request.controlling_user_id
      "You have taken control of the Money Request: #{self.money_request.name}"
    else
      "#{self.money_request.controlling_user.name} has has taken control of the Money Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.controlling_user_id
      "You have taken control of the Money Request.<br/><br/>Money Request: \"#{self.money_request.name}\""
    else
      "#{self.money_request.controlling_user.name} has has taken control of the Money Request which was awaiting your review.<br/><br/>Money Request: \"#{self.money_request.name}\""
    end
  end

end
