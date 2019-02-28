class Event::EPurchaseOrder::Reject < Event::EPurchaseOrder::Base
  attr_accessor :rejecting_user

  def init
    super
    self.rejecting_user = self.purchase_order.trails.last.action_user rescue nil
  end

  def validate
    super
    unless self.rejecting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_order_reject)
  end

  def action_name
    'Purchase Order Rejected'
  end

  def affected_users
    # User::AssociatedUsers::Index.(self.user, document: self.purchase_order, user_before: self.user, amount: purchase_order.balance_amount.value)
    self.purchase_order.affected_users(:reject)
  end

  # def get_token(user)
  #   email_authorization = params[:email_authorization]
  #   email_authorization.token
  # end


  def notification_affected_users
    # self.controlling_users
    self.purchase_order.notification_affected_users(:reject)
  end

  # def send_push_notification(user)
  #   return if user.id == report.user.id
  #   message = "#{self.report.user.name} has submitted the report: #{self.report.name}"
  #   view = UserRole.name_for(report.controlling_user_role_id)
  #   GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id, view: view
  # end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: NotificationActionType.id_for(:notify_reject),
                                             action_user_id: purchase_order.trails.last.action_user_id,
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
    if user == self.rejecting_user
      "You rejected the purchase order : #{self.purchase_order.po_number}"
    else
      "#{rejecting_user.name} has rejected the purchase order: #{self.purchase_order.po_number}"
    end
  end

  def mailer_body(user)
    if user == self.rejecting_user
      "You have rejected the purchase order: #{self.purchase_order.po_number}"
    else
      "#{self.rejecting_user.name} has rejected the purchase order: #{self.purchase_order.po_number}"
    end
  end

  # def report_view_role(user)
  #   if user.id == report.user_id
  #     return nil
  #   elsif user.id == report.controlling_user_id
  #     return report.controlling_user_role_id
  #   end
  # end
end
