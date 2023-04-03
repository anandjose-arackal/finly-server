class ApprovalTatReportsMailer < ApplicationMailer

  def send_mail(email, subject, body, file_name, file)
    attachments[file_name.to_s] = file unless file_name.nil? 
    @body = body
    mail to: email, subject: subject, template_name: 'template'
  end

end
