class Event::EMoneyRequest::EComment::Create < Event::EMoneyRequest::Base
  attr_accessor :comment

  def init
    super
    self.comment = self.money_request.comments.last rescue nil
  end

  def validate
    unless self.comment.present?
      add_message :error, 'Error loading comment'
    end
  end

  def event_id
    NotifierType.money_request_comment_id
  end

  def affected_users
    users = self.money_request.associated_users nil, include_roles: true
    users.reject { |r| r == self.user }
  end

  def send_push_notification(user)
    content = comment.content
    comment_user = comment.user
    message = "#{comment_user.name} added a comment: #{content}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user, role)
    notification = user.notifications.create(notification_type_id: NotificationType.advance_request_id,
                                             action_type_id: NotificationActionType.notify_comment_id,
                                             action_user_id: self.user.id,
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
    comment_user = comment.user
    "#{comment_user.name} has commented on the Advance Request: #{self.money_request.name}"
  end

  def mailer_body(user)
    content = comment.content
    comment_user = comment.user
    "#{comment_user.name} has comment on the Advance Request '#{self.money_request.name}'<br/><br/>'#{content}'"
  end

  def mailer_button_name(user)
    'View Advance Request'
  end

end