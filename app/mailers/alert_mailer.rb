class AlertMailer < ApplicationMailer

  def send_mail(presenter)
    return unless presenter.validate
    @body_title = presenter.body_title
    @body_description = presenter.body_description
    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end