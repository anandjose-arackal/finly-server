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
    NotifierType.id_for(:report_expense_reject)
  end

  def action_name
    "Report Expense Rejected"
  end

  def affected_users
    Report::AssociatedUsers.(self.user, report: self.report, user_before: self.user)
  end

  def send_push_notification(user)
    return unless user.id == report.user_id
    message = "Expense rejected : #{self.rejected_expense}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)
    roles = Report::ActionUserRole.(user, {report: report, user_id: user.id})
    notification = user.notifications.create(notification_type_id: NotificationType.id_for(:expense),
                                             action_type_id: NotificationActionType.id_for(:notify_reject),
                                             action_user_id: self.user.id,
                                             object_id: rejected_expense.id,
                                             object_type: "Expense",
                                             path_object_id: report.id,
                                             path_object_type: "Report",
                                             read: false,
                                             timestamp: DateUtils.local_date_time,
                                             view_role_id: roles.first
    )
    notification.save
  end

  def mailer_subject(user)
    if user == self.report.controlling_user
      "You rejected the expense : #{rejected_expense.merchant_name}"
    else
      "#{self.report.controlling_user.name} has rejected expense: #{rejected_expense.merchant_name}"
    end
  end

  def mailer_body(user)
    if user == self.report.controlling_user
      "You rejected the expense : #{rejected_expense.merchant_name} in report: #{self.report.name}"
    else
      "#{self.report.controlling_user.name} has rejected the expense at #{self.rejected_expense.merchant_name} in report: '#{self.report.name}'"
    end
    
  end

  def set_presenter_params(user)
    super(user)
    params[:rejected_expenses] = [rejected_expense]
  end
end