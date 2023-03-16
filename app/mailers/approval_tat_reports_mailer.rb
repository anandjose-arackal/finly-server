class ApprovalTatReportsMailer < ApplicationMailer

  def send_mail(email, subject, body, file)
    attachments["tat_attachment"] = file
    @body = body
    mail to: email, subject: subject, template_name: 'template'
  end

end
