class Event::EInvoice::Retract < Event::EInvoice::Base

  def event_id
    NotifierType.id_for(:invoice_retract)
  end

  def action_name
    "Invoice Retracted"
  end

  def affected_users
    # users = User::AssociatedUsers::Index.(self.user, document: self.invoice, amount: invoice.net_amount.value)
    # users.reject { |r| r == self.user}
    self.invoice.affected_users(:retract)
  end

  def notification_affected_users
    # users = User::AssociatedUsers::Index.(self.user, document: self.invoice, amount: invoice.net_amount.value)
    # users.reject { |r| r == self.user}
    self.invoice.notification_affected_users(:retract)
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:invoice),
                                             action_type_id: NotificationActionType.id_for(:notify_retract),
                                             action_user_id: invoice.created_by.id,
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
    if user.id == invoice.created_by.id
      "Invoice retracted : #{self.invoice.invoice_number}"
    else
      "#{invoice.created_by.name} has retracted the invoice: #{self.invoice.invoice_number}"
    end
  end

  def mailer_body(user)
    if user.id == invoice.created_by.id
      "You have successfully retracted the invoice : #{self.invoice.invoice_number}"
    else
      "#{invoice.created_by.name} has retracted the invoice '#{self.invoice.invoice_number}'."
    end
  end

end
