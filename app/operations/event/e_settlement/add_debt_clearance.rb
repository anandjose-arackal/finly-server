class Event::ESettlement::AddDebtClearance < Event::ESettlement::Base

  def event_id
    NotifierType.id_for(:settlement_debt_clearance)
  end

  def send_push_notification(user)

  end

  def action_name
    "Cash Deducted from Cash on Hand"
  end

  def set_notification(user)
    notification = user.notifications.create( notification_type_id: NotificationType.id_for(:payment),
                                              action_type_id: NotificationActionType.id_for(:notify_cash_withdrawal),
                                              action_user_id: payment.initiating_user.id,
                                              object_id: payment.id,
                                              object_type: "Payment",
                                              path_object_id: payment.id,
                                              path_object_type: "Payment",
                                              read: false,
                                              timestamp: DateUtils.local_date_time,
                                              amount_attributes: {value: payment.amount.value,
                                                                  currency_id: 1}
    )
    notification.save
  end

  def mailer_subject(user)
    "Money Deducted from Cash on Hand"
  end

  def mailer_body(user)
    "This is to notify you that an amount of ₹#{payment.amount.value} has been deducted from your Cash on Hand by #{payment.initiating_user.name}"
  end

end
