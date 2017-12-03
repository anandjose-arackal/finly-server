class AlertMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @body = presenter.body
    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end