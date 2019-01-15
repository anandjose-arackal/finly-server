class Event::EBankPaymentRequest::Retract < Event::EBankPaymentRequest::Base

  attr_accessor :roles

  def event_id
    NotifierType.id_for(:bank_payment_request_retract)
  end

  def action_name
    "Payment Order Retracted"
  end

  def affected_users
    # users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.bank_payment_request.bank_payment_request_trails.last.modified_user)
    users = self.bank_payment_request.associated_users(:retract)
    users.reject { |r| r == self.user}
  end

  def notification_affected_users
    # users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.bank_payment_request.bank_payment_request_trails.last.modified_user)
    users = self.bank_payment_request.associated_users(:retract)
    users.reject { |r| r == self.user}
  end

  def set_notification(user)
    self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_retract),
                                             action_user_id: bank_payment_request.owner_id,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if user.id == bank_payment_request.user.id
      "Payment Order retracted : #{self.bank_payment_request.name}"
    else
      "#{bank_payment_request.user.name} has retracted the payment order: #{self.bank_payment_request.name}"
    end
  end

  def mailer_body(user)
    if user.id == bank_payment_request.user.id
      "You have successfully retracted the payment order : #{self.bank_payment_request.name}"
    else
      "#{bank_payment_request.user.name} has retracted the payment order '#{self.bank_payment_request.name}'."
    end
  end

  def bank_payment_request_view_role(user)
    self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    return roles.first
  end
end