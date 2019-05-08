class Event::EVendors::Retract < Event::EVendors::Base

  attr_accessor :roles

  def event_id
    NotifierType.id_for(:bank_payment_request_retract)
  end

  def action_name
    "Vendor Retracted"
  end

  def affected_users
    # users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.document, user_before: self.document.bank_payment_request_trails.last.modified_user)
    users = self.document.affected_users(:retract)
  end

  def notification_affected_users
    # users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.document, user_before: self.document.bank_payment_request_trails.last.modified_user)
    users = self.document.notification_affected_users(:retract)
  end

  def set_notification(user)
    # self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:vendor),
                                             action_type_id: NotificationActionType.id_for(:notify_retract),
                                             action_user_id: document.created_by_id,
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
    if user.id == document.created_by.id
      "Vendor retracted : #{self.document.business_name}"
    else
      "#{document.created_by.name} has retracted the vendor: #{self.document.business_name}"
    end
  end

  def mailer_body(user)
    if user.id == document.created_by.id
      "You have successfully retracted the vendor: #{self.document.business_name}"
    else
      "#{document.created_by.name} has retracted the vendor '#{self.document.business_name}'."
    end
  end
end