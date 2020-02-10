class Event::EPurchaseRequest::Reject < Event::EPurchaseRequest::Base
  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.purchase_request.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_request_reject)
  end

  def action_name
    'Purchase Request Rejected'
  end

  def affected_users
    self.purchase_request.affected_users(:reject)
  end

  def notification_affected_users
    self.purchase_request.notification_affected_users(:reject)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_request),
                                             action_type_id: NotificationActionType.id_for(:notify_reject),
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
    if user == self.rejecting_user
      "You rejected the purchase request : #{self.purchase_request.order_number}"
    else
      "#{rejecting_user.name} has rejected the purchase request: #{self.purchase_request.order_number}"
    end
  end

  def mailer_body(user)
    if user == self.rejecting_user
      "You have rejected the purchase request: #{self.purchase_request.order_number}"
    else
      "#{self.rejecting_user.name} has rejected the purchase request: #{self.purchase_request.order_number}"
    end
  end

end
