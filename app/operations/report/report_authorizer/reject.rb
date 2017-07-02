class Report::ReportAuthorizer::Reject < Report::ReportAuthorizer::Base
  def process
    params[:report_id] = self.report.id
    result = Report::Reject.(self.user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      add_message :failure, result.messages[:failure]
    else
      add_message :success, "Successfully Rejected Report"
    end
  end
end