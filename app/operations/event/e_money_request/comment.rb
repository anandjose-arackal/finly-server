class Event::EMoneyRequest::EComment < Event::EMoneyRequest::Base
  attr_accessor :comment

  def init
    self.comment = report.comments.last rescue nil
  end

  def validate
    unless self.comment.present?
      messages[:error] << 'Error loading comment'
    end
  end

  def event_id
    Event.report_comment_id
  end

  def affected_users
    users = self.report.associated_users
    users.delete(self.user)
    users
  end

  def send_push_notification(user)
    content = comment.content
    comment_user = comment.user
    message = "#{comment_user.name} added a comment: #{content}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

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

  def mailer_button_name
    'View Report'
  end

end
