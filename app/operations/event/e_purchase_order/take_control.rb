class Event::EPurchaseOrder::TakeControl < Event::EPurchaseOrder::Base

  def event_id
    NotifierType.id_for(:purchase_order_take_control)
  end

  def action_name
    "Purchase Order Taken Control of"
  end

  def affected_users
    self.purchase_order.affected_users(:take_control)
  end

  def notification_affected_users
    self.purchase_order.notification_affected_users(:take_control)
  end

  def send_push_notification(user)
    return unless self.purchase_order.document_level_reviewer_mappings.with_level_id(purchase_order.controlling_level_id).pluck(:reviewer_id).include?(user.id)
    last_trail = self.purchase_order.trails.last rescue nil
    message = "#{last_trail.action_user.name} has taken control of the purhchase order : #{self.purchase_order.name}"
    view = 'manager'
    GcmMessenger.push user, purchase_order_id: self.purchase_order.id, message: message, event_id: event_id, view: view
  end

  def set_notification(user)
    last_trail = purchase_order.trails&.last
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: NotificationActionType.id_for(:notify_take_control),
                                             action_user_id: (last_trail.action_user_id rescue nil),
                                             object_id: purchase_order.id,
                                             object_type: "PurchaseOrder",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "PurchaseOrder",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app]
                                            )
    notification.save
  end

  def mailer_subject(user)
    if user.id == purchase_order.trails.last.action_user_id
      "You have taken control of the purchase order: #{self.purchase_order.po_number}"
    else
      "#{self.purchase_order.trails.last.action_user.name} has taken control of the purchase order: #{self.purchase_order.po_number}"
    end
  end

  def mailer_body(user)
    if user.id == purchase_order.trails.last.action_user_id
      "You have taken control of the purchase order.<br/><br/>PurchaseOrder: \"#{self.purchase_order.po_number}\""
    else
      "#{self.purchase_order.trails.last.action_user.name} has taken control of the purchase order which was awaiting your review.<br/><br/>PurchaseOrder: \"#{self.purchase_order.po_number}\""
    end
  end

  def purchase_order_view_role(user)
    if self.user.id == user.id
      UserRole.id_for(:admin)
    elsif purchase_order.user.id == user.id
      UserRole.id_for(:employee)
    else
      UserRole.id_for(:manager)
    end
  end

end
