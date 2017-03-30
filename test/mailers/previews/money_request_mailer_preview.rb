Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

class MoneyRequestMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/money_request_mailer/submit
  def submit
    event = Event::EMoneyRequest::Submit.new(User.first, {money_request: MoneyRequest.first})
    event.init
    body = event.mailer_body(User.first)
    subject = event.mailer_subject(User.first)
    MoneyRequestMailer.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(event.user, {money_request: MoneyRequest.first, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:money_request_submit), action_name: "Money Request Submitted"}))
  end

  # http://localhost:3001/rails/mailers/money_request_mailer/approve
  def approve
    event = Event::EMoneyRequest::Approve.new(User.first, {money_request: MoneyRequest.first})
    event.init
    body = event.mailer_body(User.first)
    subject = event.mailer_subject(User.first)
    MoneyRequestMailer.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(event.user, {money_request: MoneyRequest.first, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:money_request_approve), action_name: "Money Request Approved"}))

  end

  # http://localhost:3001/rails/mailers/money_request_mailer/retract
  def retract
    event = Event::EMoneyRequest::Retract.new(User.first, {money_request: MoneyRequest.first})
    event.init
    body = event.mailer_body(User.first)
    subject = event.mailer_subject(User.first)
    MoneyRequestMailer.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(event.user, {money_request: MoneyRequest.first, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:money_request_retract), action_name: "Money Request Retracted"}))

  end

  # http://localhost:3001/rails/mailers/money_request_mailer/reject
  def reject
    event = Event::EMoneyRequest::Reject.new(User.first, {money_request: MoneyRequest.first})
    event.init
    body = event.mailer_body(User.first)
    subject = event.mailer_subject(User.first)
    MoneyRequestMailer.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(event.user, {money_request: MoneyRequest.first, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:money_request_reject), action_name: "Money Request Rejected"}))

  end

  # http://localhost:3001/rails/mailers/money_request_mailer/comment
  def comment
    comment = MoneyRequest.first.comments.build(comment_action_id: MoneyRequestCommentAction.id_for(:comment), user_id: User.first.id, content: "Some stupid shit").save
    event = Event::EMoneyRequest::EComment::Create.new(User.first, {money_request: MoneyRequest.first})
    event.init
    body = event.mailer_body(User.first)
    subject = event.mailer_subject(User.first)
    MoneyRequestMailer.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(event.user, {money_request: MoneyRequest.first, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:money_request_comment), action_name: "New Money Request Comment", comment_body: "Are you kidding me? What're you trying to do, buy America?"}))

  end

  # http://localhost:3001/rails/mailers/money_request_mailer/take_control
  def take_control
    event = Event::EMoneyRequest::TakeControl.new(User.first, {money_request: MoneyRequest.first})
    event.init
    body = event.mailer_body(User.first)
    subject = event.mailer_subject(User.first)
    MoneyRequestMailer.send_mail(Event::EMoneyRequest::Base::MailerPresenter.new(event.user, {money_request: MoneyRequest.first, subject: subject, body: body, button_name: 'View Report', event_id: NotifierType.id_for(:money_request_submit), action_name: "Money Request Taken Control of"}))

  end
end