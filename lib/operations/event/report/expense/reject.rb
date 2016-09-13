class Event::Report::Expense::Reject < Event::Report::Base
  attr_accessor :rejected_expense

  def init
    super
    self.rejected_expense = params[:rejected_expense]
  end

  def validate
    super
    unless self.rejected_expense.present?
      messages[:error] << 'Expense not found'
    end
  end

  def event_id
    Event.report_expense_reject_id
  end

  def affected_users
    self.report.user
  end

  def send_push_notification(user)
    message = "Expense rejected : #{self.rejected_expense}"
    GcmMessenger.push user, report_id: self.report.id, message: message, event_id: event_id
  end

  def set_notification(user)

  end

  def mailer_subject(user)
    "Expense rejected : #{self.rejected_expense}"
  end

  def mailer_body(user)
    "#{self.report.controlling_user.name} has rejected the expense at #{self.rejected_expense.merchant_name} in the report: '#{self.report.name}'"
  end
end