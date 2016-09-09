class Event::Report::Approve < Event::Report::Base
  attr_accessor :approved

  def event_id
    Event.report_approve_id
  end

  def init
    super
    self.approved = (report.approved? or report.closed?) if report.present?
  end

  def affected_users
    if approved
      [self.report.controlling_user, self.report.user]
    else
      [self.report.tracks.last.user, self.report.controlling_user]
    end
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    if user.id == self.report.controlling_user.id
      "Report approved : #{self.report.name}"
    else
      if approved and user.id == self.report.user.id
        "Congratulations! Your report #{report.name} has been approved"
      else
        "#{user.name} has approved the report: #{self.report.name}"
      end
    end
  end

  def mailer_body(user)
    if user.id == report.controlling_user.id
      message = "You have successfully approved the report : #{self.report.name}"
    else
      if approved and user.id == report.user.id
        message = "Congratulations! Your report #{report.name} has been approved"
        if report.reimbursement_pending?
          message = "#{message} and is awaiting reimbursement!"
        else
          message = "#{message} and has been closed"
        end
      else
        message = "#{user.name} has approved the report '#{self.report.name}' and is currently waiting for your approval"
      end
    end
    message
  end

end
