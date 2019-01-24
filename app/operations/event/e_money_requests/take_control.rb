class Event::EMoneyRequests::TakeControl < Event::EMoneyRequests::Base

  def event_id
    NotifierType.id_for(:money_request_take_control)
  end

  def action_name
    "Money Request Taken Control of"
  end

  def affected_users
    # [self.money_request.controlling_for_user]
    self.money_request.affected_users(:take_control)
  end

  def notification_affected_users
    # [report.controlling_for_user]
    self.money_request.notification_affected_users(:take_control)
  end

  def send_push_notification(user)
    # return if user.id == money_request.controlling_user_id
    return unless self.money_request.document_level_reviewer_mappings.with_level_id(self.money_request.controlling_level_id).pluck(:reviewer_id).include?(user.id)
    last_trail = self.money_request.order(:created_at).last rescue nil
    message = "#{last_trail.action_user.name} has taken control of the Money Request : #{self.money_request.name}"
    # view = UserRole.name_for(self.money_request.controlling_for_user_role_id)
    view = 'manager'
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    # if money_request.controlling_for_user_id == user.id
    #   view_role_id = money_request.controlling_for_user_role_id
    # else
    #   view_role_id = nil
    # end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:money_request),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
                                             action_user_id: (money_request.tracks.last.action_user.id rescue nil),
                                             object_id: money_request.id,
                                             object_type: "Money Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Money Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    # if user.id == money_request.controlling_user_id
    if money_request.get_reviewers.include?(user)
      "You have taken control of the Money Request: #{self.money_request.name}"
    else
      last_trail = self.money_request.trails.order(:created_at).last rescue nil
      "#{last_trail.action_user.name} has has taken control of the Money Request: #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    # if user.id == money_request.controlling_user_id
    if money_request.get_reviewers.include?(user)
      "You have taken control of the Money Request.<br/><br/>Money Request: \"#{self.money_request.name}\""
    else
      last_trail = self.money_request.trails.order(:created_at).last rescue nil
      "#{last_trail.action_user.name} has has taken control of the Money Request which was awaiting your review.<br/><br/>Money Request: \"#{self.money_request.name}\""
    end
  end

  def money_request_view_role(user)
    # roles = MoneyRequests::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    # roles.first
    money_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end
