class Event::EPurchaseOrder::Retract < Event::EPurchaseOrder::Base

  def event_id
    NotifierType.id_for(:purchase_order_retract)
  end

  def action_name
    "Purchase Order Retracted"
  end

  def affected_users
    # users = User::AssociatedUsers::Index.(self.user, document: self.purchase_order, amount: purchase_order.balance_amount.value)
    # users.reject { |r| r == self.user}
    self.purchase_order.affected_users(:retract)
  end

  def notification_affected_users
    # users = User::AssociatedUsers::Index.(self.user, document: self.purchase_order, amount: purchase_order.balance_amount.value)
    # users.reject { |r| r == self.user}
    self.purchase_order.notification_affected_users(:retract)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: NotificationActionType.id_for(:notify_retract),
                                             action_user_id: purchase_order.user_id,
                                             object_id: purchase_order.id,
                                             object_type: "Purchase Order",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "Purchase Order",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if user.id == purchase_order.user.id
      "Purchase Order retracted : #{self.purchase_order.po_number}"
    else
      "#{purchase_order.user.name} has retracted the purchase order: #{self.purchase_order.po_number}"
    end
  end

  def mailer_body(user)
    if user.id == purchase_order.user.id
      "You have successfully retracted the purchase order : #{self.purchase_order.po_number}"
    else
      "#{purchase_order.user.name} has retracted the purchase order '#{self.purchase_order.po_number}'."
    end
  end

end
