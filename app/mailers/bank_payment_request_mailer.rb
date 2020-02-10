class BankPaymentRequestMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @data = presenter
    cc_emails = presenter.cc_emails rescue nil
    mail to: presenter.recipient, cc: cc_emails, subject: presenter.subject, template_name: 'template'
  end

  def send_failure_mail(presenter)
    return unless presenter.validate
    @data = presenter
    cc_emails = presenter.cc_emails rescue nil
    mail to: presenter.to, cc: cc_emails, subject: presenter.subject, template_name: 'failure_template'    
  end

  def notify_vendor(presenter)
  	return if presenter.failure?
    @data = presenter
    mail to: @data.to, subject: @data.subject, template_name: 'vendor_template'
  end

end