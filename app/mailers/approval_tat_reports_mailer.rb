class ApprovalTatReportsMailer < ApplicationMailer

  def send_mail(tat_params)
    @route = tat_params[:route_name]&.titleize&.singularize
    if tat_params.include?(:file_path)
      attachments["#{tat_params[:route_name]&.singularize}_approval_tat_report.xlsx"] = File.read(tat_params[:file_path]) 
      mail to: tat_params[:email], subject: "Your #{@route} TAT report is ready.", template_name: 'success_template'
    else
      mail to: tat_params[:email], subject: "Your #{@route} TAT report export has failed.", template_name: 'failure_template'
    end
  end

end
