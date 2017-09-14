class Event::EBankPaymentRequest::Submit < Event::EBankPaymentRequest::Base

  def event_id
    NotifierType.id_for(:bank_payment_request_submit)
  end

  def action_name
    "Payment Order Submitted"
  end

  def affected_users
    [self.bank_payment_request.owner, self.bank_payment_request.reload.controlling_user]
  end


  def notification_affected_users
    [bank_payment_request.controlling_user]
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: bank_payment_request.owner_id,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: bank_payment_request.controlling_user_role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == bank_payment_request.owner.id
      "Payment Order submitted : #{self.bank_payment_request.name}"
    else
      "#{self.bank_payment_request.user.name} has submitted the payment order: #{self.bank_payment_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == bank_payment_request.user.id
      "Congratulations, you have successfully submitted the payment order : #{self.bank_payment_request.name}"
    else
      "#{self.bank_payment_request.owner.name} has submitted the payment order: #{self.bank_payment_request.name} and is currently awaiting your approval."
    end
  end

end