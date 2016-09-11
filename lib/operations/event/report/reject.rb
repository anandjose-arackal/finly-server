class Event::Report::Reject < Event::Report::Base
  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.report.tracks.last.user
  end

  def validate
    super
    self.rejecting_user.present?
  end

  def event_id
    Event.report_reject_id
  end

  def affected_users
    [rejecting_user, self.report.controlling_user]
  end

  def send_push_notification(user)
    return unless user.id == report.user_id
    message = "#{rejecting_user.name} rejected the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == report.controlling_user.id
      "#{rejecting_user.name} has rejected the report: #{self.report.name}"
    else
      "Report rejected : #{self.report.name}"
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user.id
      "#{rejecting_user.name} has rejected the report: '#{self.report.name}'"
    else
      "You have rejected the report : #{self.report.name}"
    end
  end

end
