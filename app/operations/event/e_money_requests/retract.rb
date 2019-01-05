class Event::EMoneyRequests::Retract < Event::EMoneyRequests::Base

  def event_id
    NotifierType.id_for(:money_request_retract)
  end

  def action_name
    "Money Request Retracted"
  end

  def affected_users
    users = MoneyRequests::AssociatedUsers.(self.user, money_request: self.money_request, user_before: self.money_request.tracks.last.modified_user)
    users.reject { |r| r == self.user}
  end

  def send_push_notification(user)
    last_track = self.money_request.tracks.last
    return unless user.id == last_track.modified_user&.id
    message = "#{self.money_request.user.name} retracted the Money Request: #{self.money_request.name}"
    view = UserRole.name_for(last_track.modified_user_role_id)
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    roles = MoneyRequests::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:money_request),
                                             action_type_id: NotificationActionType.id_for(:notify_retract),
                                             action_user_id: money_request.user_id,
                                             object_id: money_request.id,
                                             object_type: "Money Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Money Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if user.id == money_request.user.id
      "Money Request retracted : #{self.money_request.name}"
    else
      "#{money_request.user.name} has retracted the Money Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == money_request.user.id
      "You have successfully retracted the Money Request : #{self.money_request.name}"
    else
      "#{money_request.user.name} has retracted the Money Request '#{self.money_request.name}'."
    end
  end

  def money_request_view_role(user)
    roles = MoneyRequests::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    roles.first
  end

end
