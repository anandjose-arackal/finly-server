Dir["#{Rails.root}/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3000/rails/mailers/report_mailer
class ReportMailerPreview < ActionMailer::Preview

  # http://localhost:3000/rails/mailers/report_mailer/submit
  def submit
    event = Event::Report::Submit.new(User.second, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.submit(Event::Report::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/approve
  def approve
    event = Event::Report::Approve.new(User.second, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.approve(Event::Report::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/retract
  def retract
    event = Event::Report::Retract.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.retract(Event::Report::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/comment
  def reject
    event = Event::Report::Reject.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.reject(Event::Report::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/comment
  def comment
    event = Event::Report::Comment.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.retract(Event::Report::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end


end