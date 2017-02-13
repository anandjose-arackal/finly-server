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
    NotifierType.id_for(:money_request_comment)
  end

  def affected_users
    users = MoneyRequest::AssociatedUsers.(self.user, money_request: self.money_request)
    users.reject { |r| r == self.user }
  end

  def send_push_notification(user)
    content = comment.content
    comment_user = comment.user
    message = "#{comment_user.name} added a comment: '#{content}' in money request '#{money_request.name}'"
    view = nil
    if user.id != money_request.user_id
      view = UserRole.id_for(money_request.tracks.with_modified_user(user.id).first.modified_user_role_id) rescue nil
    end
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    roles = MoneyRequest::ActionUserRole.(user, {money_request: money_request, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:advance_request),
                                             action_type_id: NotificationActionType.id_for(:notify_comment),
                                             action_user_id: self.user.id,
                                             object_id: money_request.id,
                                             object_type: "Advance Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Advance Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first
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