class Event::EBankPaymentRequest::Reject < Event::EBankPaymentRequest::Base

  attr_accessor :rejecting_user, :roles

  def init
    super
    self.rejecting_user = self.bank_payment_request.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_reject)
  end

  def action_name
    "Payment Order Rejected"
  end

  def affected_users
    # BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.user)
    self.bank_payment_request.affected_users(:reject)
  end

  def set_notification(user)
    # self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    notification = user.notifications.build(user: user,
                                            notification_type_id: NotificationType.id_for(:bank_payment_request),
                                            action_type_id: NotificationActionType.id_for(:notify_reject),
                                            action_user_id: bank_payment_request.trails.last.action_user.id,
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
    if user == self.rejecting_user
      "You rejected the Payment Order : #{self.bank_payment_request.name}"
    else
      "#{rejecting_user.name} has rejected the Payment Order: #{self.bank_payment_request.name}"
    end
  end

  def mailer_body(user)
    if user == self.rejecting_user
      "You have rejected the Payment Order : #{self.bank_payment_request.name}"
    else
      "#{rejecting_user.name} has rejected the Payment Order: '#{self.bank_payment_request.name}'"
    end
  end

  def bank_payment_request_view_role(user)
    # self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    # return roles.first
    report.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end
end