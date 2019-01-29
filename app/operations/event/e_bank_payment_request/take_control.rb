class Event::EBankPaymentRequest::TakeControl < Event::EBankPaymentRequest::Base

  def event_id
    NotifierType.id_for(:bank_payment_request_take_control)
  end

  def action_name
    "Payment Order Taken Control of"
  end

  def affected_users
    # [self.bank_payment_request.controlling_user, self.bank_payment_request.controlling_for_user]
    self.bank_payment_request.affected_users(:take_control)
  end

  def notification_affected_users
    self.bank_payment_request.notification_affected_users(:take_control)
  end


  def set_notification(user)
    # if bank_payment_request.controlling_for_user_id == user.id
    #   view_role_id = bank_payment_request.controlling_for_user_role_id
    # else
    #   view_role_id = nil
    # end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
                                             action_user_id: (bank_payment_request.trails.last.action_user.id rescue nil),
                                             object_id: bank_payment_request.id,
                                             object_type: "Payment Order",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "Payment Order",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == bank_payment_request.trails.last.action_user_id
      "You have taken control of the Payment Order: #{self.bank_payment_request.name}"
    else
      "#{self.bank_payment_request.trails.last.action_user.name} has has taken control of the Payment Order: #{self.bank_payment_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == bank_payment_request.trails.last.action_user_id
      "You have taken control of the Payment Order.<br/><br/>Payment Order: \"#{self.bank_payment_request.name}\""
    else
      "#{self.bank_payment_request.trails.last.action_user.name} has has taken control of the Payment Order which was awaiting your review.<br/><br/>Payment Order: \"#{self.bank_payment_request.name}\""
    end
  end

  def bank_payment_request_view_role(user)
    # roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    # roles.first
    if self.user.id == user.id
      UserRole.id_for(:admin)
    elsif report.user.id == user.id
      UserRole.id_for(:employee)
    else
      UserRole.id_for(:manager)
    end
  end
end