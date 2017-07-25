class VerifierPendingMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @data = presenter
    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end
