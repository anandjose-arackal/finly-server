Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3000/rails/mailers/report_mailer
class ReportMailerPreview < ActionMailer::Preview

  # http://localhost:3000/rails/mailers/report_mailer/submit
  def submit
    event = Event::EReport::Submit.new(User.second, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/approve
  def approve
    event = Event::EReport::Approve.new(User.second, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/retract
  def retract
    event = Event::EReport::Retract.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/comment
  def reject
    event = Event::EReport::Reject.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/comment
  def comment
    event = Event::EReport::EComment.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end

  # http://localhost:3000/rails/mailers/report_mailer/take_control
  def take_control
    event = Event::EReport::TakeControl.new(User.first, {report: Report.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    ReportMailer.send_mail(Event::EReport::Base::MailerPresenter.new(event.user, event.report, subject, body, 'View Report'))
  end


end