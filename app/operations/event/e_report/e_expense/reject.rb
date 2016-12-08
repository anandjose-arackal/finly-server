class Event::EReport::EExpense::Reject < Event::EReport::Base
  attr_accessor :rejected_expense

  def init
    super
    self.rejected_expense = params[:rejected_expense]
  end

  def validate
    super
    unless self.rejected_expense.present?
      add_message :error, 'Expense not found'
    end
  end

  def event_id
    NotifierType.report_expense_reject_id
  end

  def affected_users
    self.report.associated_users self.user
  end

  def notification_affected_users
    report.associated_users
  end

  def send_push_notification(user)
    return unless user.id == report.user_id
    message = "Expense rejected : #{self.rejected_expense}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    notification = user.notifications.create(notification_type_id: NotificationType.expense_id,
                                             action_type_id: NotificationActionType.reject_id,
                                             action_user_id: self.user.id,
                                             object_id: rejected_expense.id,
                                             object_type: "Expense",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time
    )
    notification.save
  end

  def mailer_subject(user)
    unless user == self.report.controlling_user
      "#{self.report.controlling_user.name} has rejected expense: #{rejected_expense.merchant_name}"
    else
      "You rejected the expense : #{rejected_expense.merchant_name}"
    end
  end

  def mailer_body(user)
    unless user == self.report.controlling_user
      "#{self.report.controlling_user.name} has rejected the expense at #{self.rejected_expense.merchant_name} in report: '#{self.report.name}'"
    else
      "You rejected the expense : #{rejected_expense.merchant_name} in report: #{self.report.name}"
    end
    
  end
end