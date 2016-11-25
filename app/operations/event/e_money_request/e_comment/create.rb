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
    Event.money_request_comment_id
  end

  def affected_users
    users = self.money_request.associated_users
    users.reject { |r| r == self.user }
  end

  def send_push_notification(user)
    content = comment.content
    comment_user = comment.user
    message = "#{comment_user.name} added a comment: #{content}"
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user)

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