class Event::EBankPaymentRequest::EComment::Create < Event::EBankPaymentRequest::Base

  attr_accessor :comment, :roles

  def init
    super
    self.comment = self.bank_payment_request.comments.reorder(created_at: :desc).first
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_comment)
  end

  def action_name
    "New Comment on Payment Order"
  end

  def affected_users
    # users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.bank_payment_request.controlling_user)
    # users.reject { |r| r == self.user}
    self.bank_payment_request.affected_users(:comment)
  end

  def notification_affected_users
    # users = BankTransfer::PaymentRequest::Review::AssociatedUsers.(self.user, bank_payment_request: self.bank_payment_request, user_before: self.bank_payment_request.controlling_user)
    # users.reject { |r| r == self.user}
    self.bank_payment_request.notification_affected_users(:comment)
  end

  def set_notification(user)
    # self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    #ToDO - Check for other roles
    role_id = (user.id == bank_payment_request.owner_id) ? UserRole.id_for(:initiator) : UserRole.id_for(:manager)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: NotificationActionType.id_for(:notify_comment),
                                             action_user_id: bank_payment_request.owner_id,
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
    comment_user = self.comment.user
    if user.id == self.comment.user_id
      "You have commented on the payment order : #{self.bank_payment_request.name}"
    else
      "#{comment_user.name} has commented on the  payment order: #{self.bank_payment_request.name}"
    end
  end

  def mailer_body(user)
    comment_user = self.comment.user
    if user.id == self.comment.user_id
      "#{comment_user.name} has commented on the payment order : #{self.bank_payment_request.name}"
    else
      "You have commented on the payment order '#{self.bank_payment_request.name}'."
    end
  end

  def bank_payment_request_view_role(user)
    # self.roles = BankTransfer::PaymentRequest::ActionUserRole.(user, {bank_payment_request: bank_payment_request, user_id: user.id})
    # return roles.first
    bank_payment_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end
end