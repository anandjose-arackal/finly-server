class Event::EBankPaymentRequest::Credit < Event::EBankPaymentRequest::Base

  attr_accessor :crediting_user

  def init
    super
    self.crediting_user = self.bank_payment_request.trails.last.action_user
  end

  def action_name
    "Payment Order Credit Initiated"
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
    NotifierType.id_for(:bank_payment_request_credit)
  end

  def set_notification(user)
    # view_role_id = UserRole.id_for(:initiator)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_credit),
                                             action_user_id: crediting_user.id,
                                             object_id: bank_payment_request.id,
                                             object_type: "PaymentOrder",
                                             path_object_id: bank_payment_request.id,
                                             path_object_type: "PaymentOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: role_id,
                                             application: RequestStore.store[:current_app])
      notification.save
  end

  def mailer_subject(user)
    return "Credit for your payment order: #{bank_payment_request.name} has been successfully initiated!"
  end

  def mailer_body(user)
    # if bank_payment_request.owner_id == crediting_user.id
    #   return "You have successfully initiated credit for your Payment Order: #{bank_payment_request.name}"
    # else
      return "#{crediting_user.name} has successfully initiated the credit of your Payment Order: #{bank_payment_request.name}"
    # end
  end

  def bank_payment_request_view_role(user)
    # return UserRole.id_for(:initiator)
    bank_payment_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end