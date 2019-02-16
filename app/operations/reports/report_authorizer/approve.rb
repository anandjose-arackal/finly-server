class Reports::ReportAuthorizer::Approve < Reports::ReportAuthorizer::Base
  def process
    params[:report_id] = self.report.id
    result = Reports::Approve.(self.user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      add_message :failure, result.messages[:failure]
    else
      add_message :success, "Successfully Apporved Report"
    end
  end
end