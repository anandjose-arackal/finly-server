Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

# Preview all emails at http://localhost:3000/rails/mailers/settlement_mailer
class SettlementMailerPreview < ActionMailer::Preview

  # http://localhost:3000/rails/mailers/settlement_mailer/add_cash
  def add_cash
    event = Event::ESettlement::AddAdvance.new(User.second, {payment: Payment.first})
    event.init
    subject = event.mailer_subject(event.user)
    body = event.mailer_body(event.user)
    SettlementMailer.send_mail(Event::ESettlement::Base::MailerPresenter.new(event.user, event.payment, subject, body, 'View Settlement'))
  end

end
