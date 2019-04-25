class Event::EBankPaymentRequest::ApproveAndForward < Event::EBankPaymentRequest::Base

  def event_id
    NotifierType.id_for(:bank_payment_request_approve_and_foward)
  end

  def action_name
    "Payment Order Forwarded"
  end

  def affected_users
    [self.bank_payment_request.trails.last.action_user, self.bank_payment_request.reload.self.bank_payment_request.trails.last.modified_user]
  end

  def notification_affected_users
    [self.bank_payment_request.trails.last.modified_user]
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_forward),
                                             action_user_id: bank_payment_request.trails.last.action_user,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: UserRole.id_for(:admin),
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    action_user = self.bank_payment_request.trails.last.action_user
    return "#{action_user.name} has forwarded a Payment Order to you"
  end

  def mailer_body(user)
    action_user = self.bank_payment_request.trails.last.action_user
    return "#{action_user.name} has forwarded Payment Order: #{bank_payment_request.name} to you"
  end
end