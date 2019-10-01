class Event::EPurchaseRequest::Approve < Event::EPurchaseRequest::Base
  attr_accessor :approving_user

  def init
    super
    self.approving_user = self.purchase_request.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.approving_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_request_approve)
  end

  def action_name
    'Purchase Request approved'
  end

  def affected_users
    self.purchase_request.affected_users(:approve)
  end

  def notification_affected_users
    self.purchase_request.notification_affected_users(:approve)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_request),
                                             action_type_id: NotificationActionType.id_for(:notify_approve),
                                             action_user_id: purchase_request.creator_id,
                                             object_id: purchase_request.id,
                                             object_type: "PurchaseRequest",
                                             path_object_id: purchase_request.id,
                                             path_object_type: "PurchaseRequest",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user == self.approving_user
      "You approved the purchase request : #{self.purchase_request.order_number}"
    else
      "#{approving_user.name} has approveed the purchase request: #{self.purchase_request.order_number}"
    end
  end

  def mailer_body(user)
    if user == self.approving_user
      "You have approved the purchase request: #{self.purchase_request.order_number}"
    else
      "#{self.approving_user.name} has approveed the purchase request: #{self.purchase_request.order_number}"
    end
  end

end
