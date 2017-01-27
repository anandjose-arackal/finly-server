class Event::ESettlement::AddReimbursement < Event::ESettlement::Base

  attr_accessor :cash_in_hand_deduction

  def event_id
    NotifierType.id_for(:settlement_add_reimbursement)
  end

  def send_push_notification(user)

  end

  def init
    super()
    self.cash_in_hand_deduction = params[:cash_in_hand_deduction]
  end

  def set_notification(user)
    unless payment.nil?
      payment.reimbursed_reports.each do |report|
        notification = user.notifications.build(notification_type_id: NotificationType.id_for(:payment),
                                                  action_type_id: NotificationActionType.id_for(:notify_credit_reimbursement),
                                                  action_user_id: payment.initiating_user.id,
                                                  object_id: report.id,
                                                  object_type: "Report",
                                                  path_object_id: report.id,
                                                  path_object_type: "Report",
                                                  read: false,
                                                  timestamp: DateUtils.local_date_time
                                                )
        notification.save
      end
    end
    unless cash_in_hand_deduction.nil?
      cash_in_hand_deduction.cash_in_hand_settled_reports.each do |report|
        notification = user.notifications.build(notification_type_id: NotificationType.id_for(:payment),
                                                 action_type_id: NotificationActionType.id_for(:notify_cash_withdrawal_against_report_reimbursement),
                                                 action_user_id: payment.initiating_user_id,
                                                 object_id: report.id,
                                                 object_type: "Report",
                                                 path_object_id: report.id,
                                                 path_object_type: "Report",
                                                 read: false,
                                                 timestamp: DateUtils.local_date_time
                                                )
        notification.save
      end
    end
  end

  def mailer_subject(user)
    "A reimbursement of ₹#{payment.amount.value} has been processed"
  end

  def mailer_body(user)
    body = "This is to notify you that a reimbursement of ₹#{payment.amount.value} has been processed for the reports:<br>"
    i = 1
    self.payment.reimbursed_reports.each do |report|
      body += "<br>#{i}. #{report.name}"
      i += 1
    end
    body
  end

end
