class Event::EPurchaseOrder::Credit < Event::EPurchaseOrder::Base
  attr_accessor :approved, :crediting_user, :auto_approve, :payment

  def action_name
    'Purchase Order Credited'
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.payment = params[:payment]
    self.crediting_user = payment.payment_order.bank_payment_request.bank_payment_request_trails.last.action_user

    self.purchase_order = payment.purchase_order
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not found'
      return
    end
    params[:purchase_order] = self.purchase_order

    self.controlling_users = []

  end

  def validate
    super
    unless self.crediting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:purchase_order_credit)
  end

  def affected_users
    [purchase_order.user]
  end

  def notification_affected_users
    [purchase_order.user]
  end

  def set_notification(user)
    notify_type = NotificationActionType.id_for(:notify_credit)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:purchase_order),
                                             action_type_id: notify_type,
                                             action_user_id: (self.crediting_user&.id),
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
    "Congratulations! Your purchase order #{purchase_order.po_number} has been credited"
  end

  def mailer_body(user)
    "Payment of &#8377;#{payment.amount.value} has been processed by #{crediting_user.name} against your purchase order #{purchase_order.po_number}."
  end
end
