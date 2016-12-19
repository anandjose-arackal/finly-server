class Event::EMoneyRequest::Reject < Event::EMoneyRequest::Base
  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.money_request.tracks.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.money_request_reject_id
  end

  def affected_users
    self.money_request.associated_users self.user, include_roles: true
  end

  def send_push_notification(user)
    return unless user.id == money_request.user_id
    message = "#{rejecting_user.name} rejected the Advance Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user, role)
    notification = user.notifications.build(user: user,
                                            notification_type_id: NotificationType.advance_request_id,
                                            action_type_id: NotificationActionType.notify_reject_id,
                                            action_user_id: money_request.tracks.last.action_user.id,
                                            object_id: money_request.id,
                                            object_type: "Advance Request",
                                            path_object_id: money_request.id,
                                            path_object_type: "Advance Request",
                                            read: false,
                                            timestamp: DateUtils.local_date_time,
                                            view_role_id: role[:roles].first
    )
    notification.save
  end

  def mailer_subject(user)
    unless user == self.rejecting_user
      "#{rejecting_user.name} has rejected the Advance Request: #{self.money_request.name}"
    else
      "You rejected the Advance Request : #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    unless user == self.rejecting_user
      "#{rejecting_user.name} has rejected the Advance Request: '#{self.money_request.name}'"
    else
      "You have rejected the Advance Request : #{self.money_request.name}"
    end
  end

end
