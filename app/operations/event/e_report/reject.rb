class Event::EReport::Reject < Event::EReport::Base
  attr_accessor :rejecting_user, :roles

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
    NotifierType.id_for(:report_reject)
  end

  def action_name
    "Report Rejected"
  end

  def affected_users
    Reports::AssociatedUsers.(self.user, report: self.report, user_before: self.user)
  end

  def send_push_notification(user)
    return unless user.id == report.user_id
    message = "#{rejecting_user.name} rejected the report: #{self.report.name}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    self.roles = Reports::ActionUserRole.(user, {report: report, user_id: user.id})
    notification = user.notifications.build(user: user,
                                            notification_type_id: NotificationType.id_for(:report),
                                            action_type_id: NotificationActionType.id_for(:notify_reject),
                                            action_user_id: report.tracks.last.action_user.id,
                                            object_id: report.id,
                                            object_type: "Report",
                                            path_object_id: report.id,
                                            path_object_type: "Report",
                                            read: false,
                                            timestamp: DateUtils.local_date_time,
                                            view_role_id: roles.first,
                                            application: RequestStore.store[:current_app]
                                            )
    notification.save
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

  def report_view_role(user)
    self.roles = Reports::ActionUserRole.(user, {report: report, user_id: user.id})
    return roles.first
  end

end
