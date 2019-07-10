class Event::EVendors::Update < Event::EVendors::Base

  def event_id
    NotifierType.id_for(:vendor_update)
  end

  def action_name
    "Vendor Details Updated"
  end

  def affected_users
    # [self.bank_payment_request.owner, self.bank_payment_request.reload.controlling_user]
    users = self.document.affected_users(:approve)
  end


  def notification_affected_users
    self.document.notification_affected_users(:approve)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:vendor),
                                             action_type_id: NotificationActionType.id_for(:notify_update),
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
    "Vendor details updated for: #{self.document.business_name}"
  end

  def mailer_body(user)
    "Vendor details for #{self.document.business_name} were updated by #{user.name} \n" +
    if params[:vendor_changes].present?
      "These were the changes: \n" +
      if params[:vendor_changes][:bank_account_changed].present?
        
      end
    end
  end
end
