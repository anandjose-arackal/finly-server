class ApprovalTatReportsMailer < ApplicationMailer

  def send_mail(email, subject, body, file = nil)
    attachments["Approval_tat_report"] = File.read(excel_file_path)
    @body = body
    mail to: email, subject: subject, template_name: 'template'
  end

end
