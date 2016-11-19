class Event::EReport::Reject < Event::EReport::Base
  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.report.tracks.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    Event.report_reject_id
  end

  def affected_users
    self.report.associated_users self.user
  end

  def send_push_notification(user)
    return unless user.id == report.user_id
    message = "#{rejecting_user.name} rejected the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    unless user == self.rejecting_user
      "#{rejecting_user.name} has rejected the report: #{self.report.name}"
    else
      "You rejected the report : #{self.report.name}"
    end
  end

  def mailer_body(user)
    unless user == self.rejecting_user
      "#{rejecting_user.name} has rejected the report: '#{self.report.name}'"
    else
      "You have rejected the report : #{self.report.name}"
    end
  end

end
