class Event::EPurchaseRequest::TakeControl < Event::EPurchaseRequest::Base

  def event_id
    NotifierType.id_for(:purchase_request_take_control)
  end

  def action_name
    "Purchase Request Taken Control"
  end

  def affected_users
    self.purchase_request.affected_users(:take_control)
  end

  def notification_affected_users
    self.purchase_request.notification_affected_users(:take_control)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_request),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
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
    if user.id == purchase_request.trails.last.action_user_id
      "You have taken control of the purchase request: #{self.purchase_request.order_number}"
    else
      "#{self.purchase_request.trails.last.action_user.name} has taken control of the purchase request: #{self.purchase_request.order_number}"
    end
  end

  def mailer_body(user)
    if user.id == purchase_request.trails.last.action_user_id
      "You have taken control of the purchase request.<br/><br/>Purchaserequest: \"#{self.purchase_request.order_number}\""
    else
      "#{self.purchase_request.trails.last.action_user.name} has taken control of the purchase request which was awaiting your review.<br/><br/>Purchaserequest: \"#{self.purchase_request.order_number}\""
    end
  end

end
