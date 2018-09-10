Dir["#{Rails.root}/app/operations/event/*.rb"].each {|file| require file }

class ProcurementMailerPreview < ActionMailer::Preview

  # http://localhost:3001/rails/mailers/bank_payment_request_mailer/submit
  def purchase_order_action_mailer
    request = BankPaymentRequest.first
    event = Event::EBankPaymentRequest::Submit.new(request.owner, bank_payment_request: request)
    event.init
    mailer_subject = event.mailer_subject(request.owner)
    mailer_body = event.mailer_body(request.owner)
    BankPaymentRequestMailer.send_mail(Event::EBankPaymentRequest::Base::PaymentRequestMailerPresenter.new(request.owner, {bank_payment_request: request, action_name: "Payment Order Submitted", subject: mailer_subject, body: mailer_body, event_id: NotifierType.id_for(:bank_payment_request_submit)}))
  end

  def retract

  end

  def invoice_action_mailer
    invoice = Invoice.with_procurement.last
    user = invoice.created_by
    event = Event::EInvoice::Submit.new(user, invoice: invoice)
    event.init
    params = {
      invoice: invoice,
      user: user,
      body_val: event.mailer_body(user),
      body_val: "Hello ther!",
      subject: event
    }

    # self.subject_val = params[:subject]
    # self.button_val = params[:button_name]
    # self.event_id = params[:event_id]
    # self.action_name = params[:action_name]
    # self.comment_body = params[:comment_body]

    ProcurementMailer.send_invoice_mail(Event::EInvoice::Base::MailerPresenter.new(user, params))

  end

end