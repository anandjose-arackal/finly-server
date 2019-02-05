class Event::EBankPaymentRequest::CreditConfirm < Event::EBankPaymentRequest::Base

  attr_accessor :crediting_user

  def init
    super
    self.crediting_user = self.bank_payment_request.trails.last.action_user
  end

  def action_name
    "Payment Order Credit Completed"
  end

  def validate
    super
    unless self.crediting_user.present?
      add_message :error, 'Crediting user not found'
    end
  end

  def affected_users
    [bank_payment_request.owner]
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_credit_confirm)
  end

  def set_notification(user)
    view_role_id = UserRole.id_for(:initiator)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_credit_confirmation),
                                             action_user_id: crediting_user.id,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: view_role_id,
                                             application: RequestStore.store[:current_app],
                                             amount_attributes: {value: bank_payment_request&.payment_order&.amount_processed&.value, currency_id: 1}
    )
    notification.save
  end

  def mailer_subject(user)
    status = bank_payment_request.payment_order&.payment_order_status&.name&.humanize
    return "Credit for your payment order: #{bank_payment_request.name} was #{status}!"
  end

  def mailer_body(user)
    if bank_payment_request.owner_id == crediting_user.id
      status = bank_payment_request.payment_order&.payment_order_status&.name&.humanize
      return "Credit for your Payment Order: #{bank_payment_request.name} has been successfully executed, and was #{status}!"
    end
  end

  def bank_payment_request_view_role(user)
    return UserRole.id_for(:initiator)
  end
end