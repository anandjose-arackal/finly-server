class VerifierPendingMailer < ApplicationMailer

  def send_mail(presenter)
    @data = presenter
    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end
