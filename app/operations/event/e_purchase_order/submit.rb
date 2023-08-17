class Event::EPurchaseOrder::Submit < Event::EPurchaseOrder::Base
  def event_id
    NotifierType.id_for(:purchase_order_submit)
  end

  def action_name
    'Purchase Order Submitted'
  end

  def affected_users
    users = self.purchase_order.affected_users(:submit)
    if purchase_order.purchase_request_items.present?
      users += purchase_request_creator
    end

    users
  end

  def notification_affected_users
    self.purchase_order.notification_affected_users(:submit)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: NotificationActionType.id_for(:notify_submit),
                                             action_user_id: purchase_order.user_id,
                                             object_id: purchase_order.id,
                                             object_type: "Purchase Order",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "Purchase Order",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app]
    )
    notification.save
  end

  def mailer_subject(user)
    if user.id == po_user.id
      "Purchase Order submitted : #{po_number}"
    else
      "#{po_user_name} has submitted Purchase Order : #{po_number}"
    end
  end

  def mailer_body(user)
    binding.pry
    if user.id == po_user.id
      "Congratulations, you have successfully submitted the purchase order : #{po_number}"
    elsif purchase_request_creator.present? && purchase_request_creator.include?(user)
      "#{po_user_name} has submitted purchase order: #{po_number} and is currently awaiting approval."
    else
      "#{po_user_name} has submitted purchase order: #{po_number} and is currently awaiting your approval."
    end
  end

  def po_user
    @po_user ||= purchase_order.user
  end

  def po_user_name
    @po_user_name ||= po_user.name
  end

  def po_number
    @po_number ||= purchase_order.po_number
  end
end
