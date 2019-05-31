class Event::EInvoice::Credit < Event::EInvoice::Base
  attr_accessor :approved, :crediting_user, :auto_approve, :payment

  def action_name
    'Invoice Credited'
  end

  def pre_validate
    unless user.present?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.payment = params[:payment]
    self.crediting_user = payment.payment_order.bank_payment_request.trails.last.action_user

    self.invoice = payment.invoice
    unless self.invoice.present?
      add_message :error, 'Invoice not found'
      return
    end
    params[:invoice] = self.invoice

    self.controlling_users = []

  end

  def validate
    super
    unless self.crediting_user.present?
      add_message :error, 'User not found'
    end
  end

  def event_id
    NotifierType.id_for(:invoice_credit)
  end

  def affected_users
    [invoice.created_by]
  end

  def notification_affected_users
    [invoice.created_by]
  end

  def set_notification(user)
    notify_type = NotificationActionType.id_for(:notify_credit)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:invoice),
                                             action_type_id: notify_type,
                                             action_user_id: (self.crediting_user&.id),
                                             object_id: invoice.id,
                                             object_type: "Invoice",
                                             path_object_id: invoice.id,
                                             path_object_type: "Invoice",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             application: RequestStore.store[:current_app])
    notification.save
  end

  def mailer_subject(user)
    "Congratulations! Your invoice #{invoice.invoice_number} has been credited"
  end

  def mailer_body(user)
    "Payment of &#8377;#{payment.amount.value} has been processed by #{crediting_user.name} against your invoice number #{invoice.invoice_number}."
  end
end
