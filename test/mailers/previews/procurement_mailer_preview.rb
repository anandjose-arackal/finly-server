class ProcurementMailerPreview < ActionMailer::Preview
  def procure_mail
    ActsAsTenant.current_tenant = Company.first
    user = User.first
    params = {
      invoice: Invoice.find(10593),
      body: "boyd",
      subject: "sub",
      button_name: "bottun",
      event_id: "evnt",
      action_name: "action",
      comment_body: "comment",
      email_based_approval: true
    }
    ProcurementMailer.send_invoice_mail(Event::EInvoice::Base::MailerPresenter.new(user, params))
#also set set_email_approval_mail as true in event/e_invoice/base.rb
#hit http://localhost:3001/rails/mailers/procurement_mailer/procure_mail to test
  end

  # http://localhost:3001/rails/mailers/procurement_mailer/modified_invoice_mail
  def modified_invoice_mail
    # payment = Payment.unscoped.find(10277) # sent from utr
    payment = Payment.unscoped.find(10278) # sent from mark as credit
    
    ActsAsTenant.current_tenant = payment.company
    
    invoice = payment.invoice
    document_owner = invoice.created_by

    if SendInvoiceEmailOnUtrUpdateToggle.new(document_owner).enabled?
      einvoice = Event::EInvoice::UtrUpdate.new(document_owner, { payment: payment })
    else
      einvoice = Event::EInvoice::Credit.new(document_owner, { payment: payment })
    end
    
    einvoice.init

    params = {
      payment: payment,
      invoice: invoice,
      subject: einvoice.mailer_subject(document_owner),
      body: einvoice.mailer_body(document_owner),
      button_name: einvoice.mailer_button_name(document_owner),
      event_id: einvoice.event_id,
      action_name: einvoice.action_name
    }

    ProcurementMailer.send_invoice_mail(Event::EInvoice::Base::MailerPresenter.new(document_owner, params))
  end

end