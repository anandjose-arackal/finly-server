class Event::EPurchaseOrder::Unapprove < Event::EPurchaseOrder::Base
  attr_accessor :approved, :approving_user, :auto_approve

  def action_name
    'Purchase Order Unapproved'
  end

  def validate
    super
    unless self.approving_user.present? or auto_approve
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_order_unapprove)
  end

  def affected_users
    # if approved
    #   if auto_approve
    #     return [self.purchase_order.user]
    #   end
    #   [self.purchase_order.trails.last.action_user, self.purchase_order.user]
    # else
    #   users = [self.purchase_order.trails.last.action_user]
    #   if controlling_users.present?
    #     controlling_users.each do |user|
    #       users.push(user)
    #     end
    #   end
    #   users
    # end
    self.purchase_order.affected_users(:unapprove)
  end

  def notification_affected_users
    # if approved
    #   [purchase_order.user]
    # else
    #   self.controlling_users
    # end
    self.purchase_order.notification_affected_users(:unapprove)
  end

  def set_notification(user)
    # if approved
    #   if auto_approve
    #     notify_type = NotificationActionType.id_for(:notify_auto_approve)
    #   else
    #     notify_type = NotificationActionType.id_for(:notify_unapprove)
    #   end
    # else
    #   notify_type = NotificationActionType.id_for(:notify_awaiting_approval)
    # end
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: NotificationActionType.id_for(:notify_unapprove),
                                             action_user_id: (purchase_order.trails.last.action_user_id rescue nil),
                                             object_id: purchase_order.id,
                                             object_type: "Purchase Order",
                                             path_object_id: purchase_order.id,
                                             path_object_type: "Purchase Order",
                                             read: false,
                                             timestamp: DateUtils,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    if purchase_order.get_reviewers.include? user
      "Purchase Order unapproved : #{purchase_order.po_number}"
    else
      "#{self.purchase_order.trails.last.action_user.name} has unapproved the purchase order: #{purchase_order.po_number}"
    end
  end

  def mailer_body(user)
    if purchase_order.get_reviewers.include? user
      "You have successfully unapproved the purchase_order : #{self.purchase_order.po_number}"
    else
      "#{self.purchase_order.trails.last.action_user.name} has unapproved the purchase order: #{self.purchase_order.po_number}"
    end
  end
end
