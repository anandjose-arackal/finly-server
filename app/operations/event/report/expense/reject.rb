class Event::Report::Expense::Reject < Event::Report::Base
  attr_accessor :rejected_expense

  def init
    super
    self.rejected_expense = params[:rejected_expense]
  end

  def event_id
    Event.report_expense_reject_id
  end

  def affected_users
    self.report.user
  end

  def send_push_notification(user, gcm_sender_id)

  end

  def set_notification(user)

  end

  def mailer_subject(user)
    "Expense rejected : #{}"
  end

  def mailer_body(user)
    "#{user.name} has rejected the expense at #{rejected_expense.merchant_name} in the report: '#{self.report.name}'"
  end
end