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
      comment_body: "comment"
    }
    ProcurementMailer.send_invoice_mail(Event::EInvoice::Base::MailerPresenter.new(user, params))

  end

end