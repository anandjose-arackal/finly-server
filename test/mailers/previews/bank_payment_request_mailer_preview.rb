Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

class BankPaymentRequestMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/bank_payment_request_mailer/submit
  def submit
    request = BankPaymentRequest.first
    event = Event::EBankPaymentRequest::Submit.new(request.owner, bank_payment_request: request)
    event.init
    mailer_subject = event.mailer_subject(request.owner)
    mailer_body = event.mailer_body(request.owner)
    BankPaymentRequestMailer.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(request.owner, {bank_payment_request: request, action_name: "Payment Order Submitted", subject: mailer_subject, body: mailer_body, event_id: NotifierType.id_for(:bank_payment_request_submit)}))
  end

  def retract

  end

  def credit

  end

end