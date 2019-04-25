class Event::EBankPaymentRequest::Approve < Event::EBankPaymentRequest::Base

  attr_accessor :approving_user, :approved, :auto_approve

  def init
    super
    self.approving_user = self.bank_payment_request.trails.reload.last.action_user
    self.approved = (self.bank_payment_request.approved? || self.bank_payment_request.credited?) ? true : false
    self.auto_approve = params[:approve]
  end

  def action_name
    "Paymnt Order approved"
  end


  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def affected_users
    # if approved
    #   if auto_approve
    #     return [self.bank_payment_request.owner]
    #   end
    #   [self.bank_payment_request.owner]
    # else
    #   [self.bank_payment_request.controlling_user]
    # end
    self.bank_payment_request.affected_users(:approve)
  end

  def notification_affected_users
    self.bank_payment_request.notification_affected_users(:approve)
  end

  def event_id
    NotifierType.id_for(:bank_payment_request_approve)
  end

  def set_notification(user)
    if approved
      if auto_approve
        notify_type = NotificationActionType.id_for(:notify_auto_approve)
      else
        notify_type = NotificationActionType.id_for(:notify_approve)
      end
    else
      notify_type = NotificationActionType.id_for(:notify_awaiting_approval)
    end
    # view_role_id = bank_payment_request.controlling_user_role_id
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:bank_payment_request),
                                             action_type_id: notify_type,
                                             action_user_id: (self.bank_payment_request.trails.last.action_user.id rescue nil),
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
    approver_id = self.bank_payment_request.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      "Payment Order approved : #{self.bank_payment_request.name}"
    else
      if approved and user.id == self.bank_payment_request.owner.id
        if auto_approve
          return "Congratulations! Your payment order #{bank_payment_request.name} has been auto-approved"
        else
          return "Congratulations! Your payment order #{bank_payment_request.name} has been approved"
        end
      else
        "#{approving_user.name} has approved the payment order: #{self.bank_payment_request.name}"
      end
    end
  end

  def mailer_body(user)
    approver_id = self.bank_payment_request.trails.last.action_user.id rescue nil
    if approver_id.present? and user.id == approver_id
      message = "You have successfully approved the payment order : #{self.bank_payment_request.name}"
    else
      if approved and user.id == bank_payment_request.owner_id
        if auto_approve
          message = "Congratulations! Your payment order #{bank_payment_request.name} has been auto-approved"
        else
          message = "Congratulations! Your payment order #{bank_payment_request.name} has been approved"
        end
        if bank_payment_request.credit_pending?
          message = "#{message} and is awaiting credit!"
        end
      else
        message = "#{approving_user.name} has approved the payment order '#{self.bank_payment_request.name}' and is currently waiting for your approval"
      end
    end
    message
  end

  def bank_payment_request_view_role(user)
    # if user.id == bank_payment_request.owner_id
    #   return UserRole.id_for(:initiator)
    # elsif user.id == bank_payment_request.controlling_user_id
    #   return bank_payment_request.controlling_user_role_id
    # elsif user.id == self.bank_payment_request.trails.last.action_user_id
    #   return self.bank_payment_request.bank_payment_request_trails.last.action_user_role_id
    # end
    bank_payment_request.get_reviewers.include?(user) ? UserRole.id_for(:manager) : UserRole.id_for(:employee)
  end

end