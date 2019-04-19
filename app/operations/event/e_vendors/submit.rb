class Event::EVendors::Submit < Event::EVendors::Base

  def event_id
    NotifierType.id_for(:vendor_submit)
  end

  def action_name
    "Vendor Submitted for Approval"
  end

  def affected_users
    # [self.bank_payment_request.owner, self.bank_payment_request.reload.controlling_user]
    users = self.document.affected_users(:submit)
  end


  def notification_affected_users
    self.document.notification_affected_users(:submit)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:vendor),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: document.created_by_id,
                                             object_id: document.id,
                                             object_type: "YesBankVendor",
                                             path_object_id: document.id,
                                             path_object_type: "YesBankVendor",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             # view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == document.created_by_id
      "Vendor Submitted for approval: #{self.document.business_name}"
    else
      "#{self.document.created_by.name} has submitted the vendor for approval: #{self.document.business_name}"
    end
  end

  def mailer_body(user)
    if user.id == bank_payment_request.owner_id
      "Congratulations, you have successfully submitted the vendor for approval : #{self.document.business_name} to #{document.get_reviewers.map(&:name).join(", ")}"
    else
      "#{self.document.created_by.name} has submitted the vendor: #{self.document.business_name} and is currently awaiting your approval."
    end
  end
end