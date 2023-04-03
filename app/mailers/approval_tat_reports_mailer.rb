class ApprovalTatReportsMailer < ApplicationMailer

  def send_mail(email, subject, body, file_name, file)
    Rails.logger.info "Before sending tat email"
    attachments[file_name.to_s] = file unless file_name.nil? 
    Rails.logger.info "After sending tat email"
    @body = body
    mail to: email, subject: subject, template_name: 'template'
  end

end
