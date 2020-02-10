class Event::EPurchaseRequest::Submit < Event::EPurchaseRequest::Base
  def event_id
    NotifierType.id_for(:purchase_request_submit)
  end

  def action_name
    'Purchase Request Submitted'
  end

  def affected_users
    self.purchase_request.affected_users(:submit)
  end

  def notification_affected_users
    self.purchase_request.notification_affected_users(:submit)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_request),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
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
    if user.id == purchase_request.creator.id
      "Purchase Request submitted : #{self.purchase_request.order_number}"
    else
      "#{self.purchase_request.creator.name} has submitted Purchase Request : #{self.purchase_request.order_number}"
    end
  end

  def mailer_body(user)
    if user.id == purchase_request.creator.id
      "Congratulations, you have successfully submitted the purchase request : #{self.purchase_request.order_number}"
    else
      "#{self.purchase_request.creator.name} has submitted purchase request: #{self.purchase_request.order_number} and is currently awaiting your approval."
    end
  end

end
