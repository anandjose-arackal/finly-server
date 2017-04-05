class Event::EMoneyRequest::Approve < Event::EMoneyRequest::Base
  attr_accessor :approved, :approving_user, :auto_approve

  def pre_validate
    if params.blank? or params[:money_request].blank?
      add_message :error, 'Money Request not found'
      return
    end
    unless params[:money_request].is_a?(::MoneyRequest)
      add_message :error, 'Error loading Money Request'
    end
    unless user.present? or params[:auto_approve]
      add_message :error, 'User not found'
      return
    end
  end

  def init
    super
    self.approving_user = self.money_request.tracks.last.action_user
    self.approved = money_request.approved? if money_request.present?
    self.auto_approve = params[:auto_approve]
  end

  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:money_request_approve)
  end

  def action_name
    "Money Request Approved"
  end

  def affected_users
    if approved
      if auto_approve
        return [self.money_request.user]
      end
      [self.money_request.tracks.last.action_user, self.money_request.user]
    else
      [self.money_request.tracks.last.action_user, self.money_request.controlling_user]
    end
  end

  def notification_affected_users
    if approved
      [money_request.user]
    else
      [money_request.controlling_user]
    end
  end

  def send_push_notification(user)
    view = nil
    if approved
      return unless user == money_request.user
      if auto_approve
        message = "Money Request auto-approved: #{self.money_request.name}"
      else
        message = "Money Request approved: #{self.money_request.name}"
      end
    else
      return unless user == money_request.controlling_user
      message = "Money Request is awaiting your approval: #{self.money_request.name}"
      view = UserRole.name_for(money_request.controlling_user_role_id)
    end
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id, view: view
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
    view_role_id = money_request.controlling_user_role_id
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:money_request),
                                             action_type_id: notify_type,
                                             action_user_id: (money_request.tracks.last.action_user.id rescue nil),
                                             object_id: money_request.id,
                                             object_type: "Money Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Money Request",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id
    )
    notification.save
  end

  def mailer_subject(user)
    approver_id = self.money_request.tracks.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      "Money Request approved : #{self.money_request.name}"
    else
      if approved and user.id == self.money_request.user.id
        if auto_approve
          return "Congratulations! Your Money Request #{money_request.name} has been auto-approved"
        else
          "Congratulations! Your Money Request #{money_request.name} has been approved"
        end
      else
        "#{approving_user.name} has approved the Money Request: #{self.money_request.name}"
      end
    end
  end

  def mailer_body(user)
    approver_id = self.money_request.tracks.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      message = "You have successfully approved the money_request : #{self.money_request.name}"
    else
      if approved and user.id == money_request.user.id
        if auto_approve
          return "Congratulations! Your Money Request #{money_request.name} has been auto-approved"
        else
          message = "Congratulations! Your Money Request #{money_request.name} has been approved"
        end
      else
        message = "#{user.name} has approved the Money Request '#{self.money_request.name}' and is currently waiting for your approval"
      end
    end
    message
  end

  def money_request_view_role(user)
    if user.id == money_request.user_id
      return UserRole.id_for(:employee)
    elsif user.id == money_request.controlling_user_id
      return money_request.controlling_user_id
    elsif user.id == self.money_request.tracks.last.action_user_id
      return self.money_request.tracks.last.action_user_role_id
    end
  end

end
