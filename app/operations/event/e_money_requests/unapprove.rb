class Event::EMoneyRequests::Unapprove < Event::EMoneyRequests::Base

  def event_id
    NotifierType.id_for(:money_request_unapprove)
  end

  def action_name
    "Money Request Unapproved"
  end

  def affected_users
    # [self.money_request.controlling_user, self.money_request.tracks.last.modified_user]
    self.money_request.affected_users(:unapprove)
  end

  def send_push_notification(user)
    # return if user.id == money_request.controlling_user_id
    return if self.money_request.get_reviewers&.include?(user)
    message = "#{self.money_request.tails&.last.action_user&.name} unapproved the Money Request: #{self.money_request.name}"
    # view = UserRole.name_for(self.money_request.tracks.last.modified_user_role_id)
    view = 'manager'
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    # if money_request.controlling_user_id == user.id
    #   view_role_id = money_request.controlling_user_role_id
    # else
    #   view_role_id = money_request.tracks.last.modified_user_role_id
    # end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:money_request),
                                             action_type_id: NotificationActionType.id_for(:notify_unapprove),
                                             action_user_id: self.user.id,
                                             object_id: money_request.id,
                                             object_type: "Money Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Money Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if money_request.get_reviewers.include? user
      "Money Request unapproved : #{self.money_request.name}"
    else
      "#{self.money_request.trails&.last&.action_user&.name} has unapproved the Money Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if money_request.get_reviewers.include? user
      "You have successfully unapproved the Money Request : #{self.money_request.name}"
    else
      "#{self.money_request.trails&.last&.action_user&.name} has unapproved the Money Request: #{self.money_request.name}"
    end
  end

  def money_request_view_role(user)
    # if money_request.controlling_user_id == user.id
    #   return money_request.controlling_user_role_id
    # else
    #   return money_request.tracks.last.modified_user_role_id
    # end
    money_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end
