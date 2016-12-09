class Event::ESettlement::AddCashAdvance < Event::ESettlement::Base

  def event_id
    NotifierType.settlement_add_cash_advance_id
  end

  def send_push_notification(user)

  end

  def set_notification(user)
    notification = user.notifications.create( notification_type_id: NotificationType.payment_id,
                                              action_type_id: NotificationActionType.cash_load_id,
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
    "You have received a cash advance of ₹#{payment.amount.value}"
  end

  def mailer_body(user)
    "This is to notify you that a cash advance of ₹#{payment.amount.value} has been recorded by #{payment.initiating_user.name}"
  end

end