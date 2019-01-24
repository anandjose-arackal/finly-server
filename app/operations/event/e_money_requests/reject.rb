class Event::EMoneyRequests::Reject < Event::EMoneyRequests::Base
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
    NotifierType.id_for(:money_request_reject)
  end

  def action_name
    "Money Request Rejected"
  end

  def affected_users
    # MoneyRequests::AssociatedUsers.(self.user, money_request: self.money_request, user_before: self.user)
    self.money_request.affected_users(:reject)
  end

  def send_push_notification(user)
    return unless user.id == money_request.user_id
    message = "#{rejecting_user.name} rejected the Money Request: #{self.money_request.name}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)
    roles = MoneyRequests::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    notification = user.notifications.build(user: user,
                                            notification_type_id: NotificationType.id_for(:money_request),
                                            action_type_id: NotificationActionType.id_for(:notify_reject),
                                            action_user_id: money_request.tracks.last.action_user.id,
                                            object_id: money_request.id,
                                            object_type: 'Money Request',
                                            path_object_id: money_request.id,
                                            path_object_type: 'Money Request',
                                            read: false,
                                            timestamp: DateUtils.local_date_time,
                                            view_role_id: roles.first,
                                            application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    unless user == self.rejecting_user
      "#{rejecting_user.name} has rejected the Money Request: #{self.money_request.name}"
    else
      "You rejected the Money Request : #{self.money_request.name}"
    end
  end

  def mailer_body(user)
    unless user == self.rejecting_user
      "#{rejecting_user.name} has rejected the Money Request: '#{self.money_request.name}'"
    else
      "You have rejected the Money Request : #{self.money_request.name}"
    end
  end

  def money_request_view_role(user)
    # roles = MoneyRequests::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    # roles.first
    money_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end
