class Event::EReport::Approve < Event::EReport::Base
  attr_accessor :approved, :approving_user

  def init
    super
    self.approving_user = self.report.tracks.last.action_user
    self.approved = (report.approved? or report.closed?) if report.present?
  end

  def validate
    super
    self.approving_user.present?
  end

  def event_id
    NotifierType.report_approve_id
  end

  def affected_users
    if approved
      [self.report.tracks.last.action_user, self.report.user]
    else
      [self.report.tracks.last.action_user, self.report.controlling_user]
    end
  end

  def notification_affected_users
    if approved
      [report.user]
    else
      [report.controlling_user]
    end
  end

  def send_push_notification(user)
    if approved
      return unless user == report.user
      message = "Report approved: #{self.report.name}"
    else
      return unless user == report.controlling_user
      message = "Report is awaiting your approval: #{self.report.name}"
    end
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.report_id,
                                              action_type_id: NotificationActionType.approve_id,
                                              action_user_id: (report.tracks.last.action_user.id rescue nil),
                                              object_id: report.id,
                                              object_type: "Report",
                                              path_object_id: report.id,
                                              path_object_type: "Report",
                                              read: false,
                                              timestamp: DateUtils.local_date_time
                                             )
    notification.save
  end

  def mailer_subject(user)
    approver_id = self.report.tracks.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      "Report approved : #{self.report.name}"
    else
      if approved and user.id == self.report.user.id
        "Congratulations! Your report #{report.name} has been approved"
      else
        "#{approving_user.name} has approved the report: #{self.report.name}"
      end
    end
  end

  def mailer_body(user)
    approver_id = self.report.tracks.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
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
