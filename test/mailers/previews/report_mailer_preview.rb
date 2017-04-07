Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3001/rails/mailers/report_mailer
class ReportMailerPreview < ActionMailer::Preview



  # http://localhost:3001/rails/mailers/report_mailer/submit
  def submit
    event = Event::EReport::Submit.new(User.second, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:report_submit), action_name: "Report Submitted"}))
  end

  # http://localhost:3001/rails/mailers/report_mailer/approve
  def approve
    event = Event::EReport::Approve.new(User.second, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:report_approve), action_name: "Report Approved"}))
  end

  # http://localhost:3001/rails/mailers/report_mailer/retract
  def retract
    event = Event::EReport::Retract.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:report_retract), action_name: "Report Retracted"}))
  end

  # http://localhost:3001/rails/mailers/report_mailer/comment
  def reject
    event = Event::EReport::Reject.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:report_reject), action_name: "Report Rejected"}))
  end

  # http://localhost:3001/rails/mailers/report_mailer/comment
  def comment
    comment = Report.first.comments.build(report_comment_action_id: ReportCommentAction.id_for(:report_comment), user_id: User.first.id, content: "Something stupid").save
    event = Event::EReport::EComment::Create.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:report_comment), action_name: "New Report Comment", comment_body: "What the fuck happened in Vegas?"}))
  end

  # http://localhost:3001/rails/mailers/report_mailer/take_control
  def take_control
    event = Event::EReport::TakeControl.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:report_take_control), action_name: "Report Taken Control of"}))
  end

  # http://localhost:3001/rails/mailers/report_mailer/reject_expense
  def reject_expense
    event = Event::EReport::EExpense::Reject.new(User.first, {report: Report.first, rejected_expense: Report.first.expenses.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, {report: event.report, subject: subject, body: body, button_name: 'View Report', rejected_expenses: [Report.first.expenses.first], event_id: NotifierType.id_for(:report_expense_reject), action_name: "Report Expense Rejected"}))
  end


end