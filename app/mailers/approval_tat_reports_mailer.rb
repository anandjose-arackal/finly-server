class ApprovalTatReportsMailer < ApplicationMailer

  def send_mail(email, subject, body, file_name, file_path )
    attachments[file_name.to_s] = File.read(file_path) unless file_name.nil? 
    @body = body
    mail to: email, subject: subject, template_name: 'template'
  end

end
