class Event::EBankPaymentRequest::Unapprove < Event::EBankPaymentRequest::Base

  def event_id
    NotifierType.id_for(:bank_payment_request_unapprove)
  end

  def action_name
    "Payment Order Unapproved"
  end

  def affected_users
    self.bank_payment_request.affected_users(:unapprove)
  end

  def notification_affected_users
    # [self.bank_payment_request.bank_payment_request_trails.last.modified_user]
    self.bank_payment_request.notification_affected_users(:unapprove)
  end

  def set_notification(user)
    # if bank_payment_request.controlling_user_id == user.id
    #   view_role_id = bank_payment_request.controlling_user_role_id
    # else
    #   view_role_id = bank_payment_request.bank_payment_request_trails.last.modified_user_role_id
    # end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_unapprove),
                                             action_user_id: self.user.id,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if bank_payment_request.get_reviewers.include? user
      "Payment Order unapproved : #{self.bank_payment_request.name}"
    else
      "#{self.bank_payment_request.trails.last.action_user.name} has unapproved the Payment Order: #{self.bank_payment_request.name}"
    end
  end

  def mailer_body(user)
    if bank_payment_request.get_reviewers.include? user
      "You have successfully unapproved the Payment Order : #{self.bank_payment_request.name}"
    else
      "#{self.bank_payment_request.trails.last.action_user.name} has unapproved the Payment Order: #{self.bank_payment_request.name}"
    end
  end

  def bank_payment_request_view_role(user)
    # if bank_payment_request.controlling_user_id == user.id
    #   return bank_payment_request.controlling_user_role_id
    # else
    #   return bank_payment_request.bank_payment_request_trails.last.modified_user_role_id
    # end
    bank_payment_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end
end