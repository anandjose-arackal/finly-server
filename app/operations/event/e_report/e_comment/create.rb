class Event::EReport::EComment::Create < Event::EReport::Base
  attr_accessor :comment

  def init
    super
    self.comment = self.report.comments.last rescue nil
  end

  def validate
    unless self.comment.present?
      add_message :error, 'Error loading comment'
    end
  end

  def event_id
    NotifierType.id_for(:report_comment)
  end

  def affected_users
    users = Report::AssociatedUsers.(self.user, report: self.report)
    users.reject { |r| r == self.user }
  end

  def notification_affected_users
    affected_users
  end

  def send_push_notification(user)
    content = comment.content
    comment_user = comment.user
    message = "#{comment_user.name} added a comment: #{content}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    roles = Report::ActionUserRole.(user, {report: report, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                             action_type_id: NotificationActionType.id_for(:notify_comment),
                                             action_user_id: self.user.id,
                                             object_id: report.id,
                                             object_type: "Report",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first
                                            )
    notification.save
  end

  def mailer_subject(user)
    comment_user = comment.user
    "#{comment_user.name} has commented on the report: #{self.report.name}"
  end

  def mailer_body(user)
    content = comment.content
    comment_user = comment.user
    "#{comment_user.name} has comment on the report '#{self.report.name}'<br/><br/>'#{content}'"
  end

  def mailer_button_name(user)
    'View Report'
  end

end
