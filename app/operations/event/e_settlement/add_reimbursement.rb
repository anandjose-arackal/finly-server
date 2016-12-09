class Event::ESettlement::AddReimbursement < Event::ESettlement::Base

  def event_id
    NotifierType.settlement_add_reimbursement_id
  end

  def send_push_notification(user)

  end

  def set_notification(user)
    payment.reports.each do |report|
      notification = user.notifications.create( notification_type_id: NotificationType.payment_id,
                                                action_type_id: NotificationActionType.credit_reimbursement_id,
                                                action_user_id: payment.initiating_user.id,
                                                object_id: report.id,
                                                object_type: "Report",
                                                path_object_id: report.id,
                                                path_object_type: "Report",
                                                read: false,
                                                timestamp: DateUtils.local_date_time,
                                                amount_attributes: {value: report.reimbursement_amount.value,
                                                                    currency_id: 1}
                                              )
      notification.save
    end
  end

  def mailer_subject(user)
    "A reimbursement of ₹#{payment.amount.value} has been processed"
  end

  def mailer_body(user)
    body = "This is to notify you that a reimbursement of ₹#{payment.amount.value} has been processed for the reports:<br>"
    i = 1
    self.payment.reports.each do |report|
      body += "<br>#{i}. #{report.name}"
      i += 1
    end
    body
  end

end
