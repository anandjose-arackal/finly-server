class Event::EReport::Approve < Event::EReport::Base
  attr_accessor :approved, :approving_user, :auto_approve

  def pre_validate
    if params.blank? or params[:report].blank?
      add_message :error, 'Report not found'
      return
    end
    unless params[:report].is_a?(::Report)
      add_message :error, 'Error loading report'
    end
    unless user.present? or params[:auto_approve]
      add_message :error, 'User not found'
    end
  end

  def action_name
    'Report Approved'
  end

  def init
    super
    self.approving_user = self.report.trails.last.action_user
    self.approved = (report.approved? or report.closed?) if report.present?
    self.auto_approve = params[:auto_approve]
  end

  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:report_approve)
  end

  def affected_users
    # if approved
    #   if auto_approve
    #     return [self.report.user]
    #   end
    #   [self.report.tracks.last.action_user, self.report.user]
    # else
    #   [self.report.tracks.last.action_user, self.report.controlling_user]
    # end
    self.report.affected_users(:approve)
  end

  def get_token(user)
    email_authorization = params[:email_authorization].where(user_id: user.id)&.last
    token = email_authorization&.token
    token
  end

  def notification_affected_users
    self.report.notification_affected_users(:approve)
  end

  def send_push_notification(user)
    view = nil
    if approved
      return unless user == report.user
      if auto_approve
        message = "Report auto-approved: #{self.report.name}"
      else
        message = "Report approved: #{self.report.name}"
      end
    else
      return unless report.get_reviewers.include? user
      message = "Report is awaiting your approval: #{self.report.name}"
      # view = UserRole.name_for(report.controlling_user_role_id)
      view = "manager" # todo hardcoded
    end
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    if approved
      if auto_approve
        notify_type = NotificationActionType.id_for(:notify_auto_approve)
      else
        notify_type = NotificationActionType.id_for(:notify_approve)
      end
    else
      notify_type = NotificationActionType.id_for(:notify_awaiting_approval)
    end
    # view_role_id = report.controlling_user_role_id
    # view_role_id = UserRole.id_for("manager")
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:report),
                                              action_type_id: notify_type,
                                              action_user_id: (report.trails.last.action_user.id rescue nil),
                                              object_id: report.id,
                                              object_type: "Report",
                                              path_object_id: report.id,
                                              path_object_type: "Report",
                                              read: false,
                                              timestamp: DateUtils.local_date_time,
                                              view_role_id: role_id,
                                              application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    approver_id = self.report.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      "Report approved : #{self.report.name}"
    else
      if approved and user.id == self.report.user.id
        if auto_approve
          return "Congratulations! Your report #{report.name} has been auto-approved"
        else
          return "Congratulations! Your report #{report.name} has been approved"
        end
      else
        "#{approving_user.name} has approved the report: #{self.report.name}"
      end
    end
  end

  def mailer_body(user)
    approver_id = self.report.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      message = "You have successfully approved the report : #{self.report.name}"
    else
      if approved and user.id == report.user.id
        if auto_approve
          message = "Congratulations! Your report #{report.name} has been auto-approved"
        else
          message = "Congratulations! Your report #{report.name} has been approved"
        end
        if report.settlement_pending?
          message = "#{message} and is awaiting settlement!"
        else
          message = "#{message} and has been closed"
        end
      else
        message = "#{approving_user.name} has approved the report '#{self.report.name}' and is currently waiting for your approval"
      end
    end
    message
  end

  def report_view_role(user)
    if user.id == report.user_id
      return UserRole.id_for(:employee)
    # elsif user.id == report.controlling_user_id
    elsif report.get_reviewers.include?(user)
      return UserRole.id_for(:manager)
    elsif user.id == self.report.trails.last.action_user_id
      return UserRole.id_for(:manager)
    end
  end

end
