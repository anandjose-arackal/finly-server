class BankPaymentRequestMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @data = presenter
    cc_emails = presenter.cc_emails rescue nil
    mail to: presenter.recipient, cc: cc_emails, subject: presenter.subject, template_name: 'template'
  end

end