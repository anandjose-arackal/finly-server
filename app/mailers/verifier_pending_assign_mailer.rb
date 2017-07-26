class VerifierPendingAssignMailer < ApplicationMailer

  def send_mail(presenter)
    @data = presenter
    if presenter.attachment.present?
      attachments[presenter.attachment_name] = presenter.attachment
    end
    mail to: presenter.to, subject: presenter.subject, template_name: 'template'
  end

end
