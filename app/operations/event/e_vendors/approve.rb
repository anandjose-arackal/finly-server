class Event::EVendors::Approve < Event::EVendors::Base

  attr_accessor :approving_user, :approved, :auto_approve

  def init
    super
    self.approving_user = self.document.trails.reload.last.action_user
    self.approved = (self.document.approved? || self.document.auto_approved?) ? true : false
    self.auto_approve = self.document.auto_approved?
  end

  def action_name
    "Vendor approved"
  end


  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def affected_users
    self.document.affected_users(:approve)
  end

  def notification_affected_users
    self.document.notification_affected_users(:approve)
  end

  def event_id
    NotifierType.id_for(:vendor_approve)
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
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:vendor),
                                             action_type_id: notify_type,
                                             action_user_id: (self.document.trails.last.action_user.id rescue nil),
                                             object_id: document.id,
                                             object_type: "YesBankVendor",
                                             path_object_id: document.id,
                                             path_object_type: "YesBankVendor",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             # view_role_id: role_id,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    approver_id = self.document.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      "Vendor approved : #{self.document.business_name}"
    else
      if approved and user.id == self.document.created_by_id
        if auto_approve
          return "Congratulations! Vendor #{document.business_name} has been auto-approved"
        else
          return "Congratulations! Vendor #{document.business_name} has been approved"
        end
      else
        "#{approving_user.name} has approved the vendor: #{self.document.business_name}"
      end
    end
  end

  def mailer_body(user)
    approver_id = self.document.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      message = "You have successfully approved the document: #{self.document.business_name}"
    else
      if approved and user.id == document.owner_id
        if auto_approve
          message = "Congratulations! Vendor #{document.business_name} has been auto-approved"
        else
          message = "Congratulations! Vendor #{document.business_name} has been approved"
        end
      else
        message = "#{approving_user.name} has approved the vendor '#{self.document.business_name}' and is currently waiting for your approval"
      end
    end
    message
  end
end