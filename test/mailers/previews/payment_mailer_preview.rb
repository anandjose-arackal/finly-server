Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

class PaymentMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/payment_mailer/credit_confirm
  def credit_confirm
    user = User.first
    payment = Payment.find(4654)
    receiving_user = payment.receiving_user
    event = Event::EBankPaymentRequest::EPayment::CreditConfirm.new(user, payment: payment)
    event.init
    body = event.mailer_body(receiving_user)
    subject = event.mailer_subject(receiving_user)
    PaymentMailer.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(user, {payment: payment, action_name: event.action_name, subject: subject, body: body}))
  end
end