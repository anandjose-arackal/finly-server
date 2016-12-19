class Event::EMoneyRequest::Approve < Event::EMoneyRequest::Base
  attr_accessor :approved, :approving_user, :auto_approve

  def pre_validate
    if params.blank? or params[:money_request].blank?
      add_message :error, 'Advance Request not found'
      return
    end
    unless params[:money_request].is_a?(::MoneyRequest)
      add_message :error, 'Error loading Advance Request'
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
    NotifierType.money_request_approve_id
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
      [money_request.user, money_request.controlling_user]
    end
  end

  def send_push_notification(user)
    if approved
      return unless user == money_request.user
      if auto_approve
        message = "Advance Request auto-approved: #{self.money_request.name}"
      else
        message = "Advance Request approved: #{self.money_request.name}"
      end
    else
      return unless user == money_request.controlling_user
      message = "Advance Request is awaiting your approval: #{self.money_request.name}"
    end
    GcmMessenger.push user, money_request_id: self.money_request.id, message: message, event_id: event_id
  end

  def set_notification(user, role)
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
    notification = user.notifications.create(notification_type_id: NotificationType.advance_request_id,
                                             action_type_id: notify_type,
                                             action_user_id: (money_request.tracks.last.action_user.id rescue nil),
                                             object_id: money_request.id,
                                             object_type: "Advance Request",
                                             path_object_id: money_request.id,
                                             path_object_type: "Advance Request",
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
          return "Congratulations! Your Advance Request #{money_request.name} has been auto-approved"
        else
          "Congratulations! Your Advance Request #{money_request.name} has been approved"
        end
      else
        "#{approving_user.name} has approved the Advance Request: #{self.money_request.name}"
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
          return "Congratulations! Your Advance Request #{money_request.name} has been auto-approved"
        else
          message = "Congratulations! Your Advance Request #{money_request.name} has been approved"
        end
      else
        message = "#{user.name} has approved the Advance Request '#{self.money_request.name}' and is currently waiting for your approval"
      end
    end
    message
  end

end
