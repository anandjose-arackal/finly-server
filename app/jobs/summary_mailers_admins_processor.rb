class SummaryMailersAdminsProcessor < ActiveJob::Base

  def perform
    return unless [0, 30].include?(DateTime.now.minute)
    SummaryMailer::CompanyAdmin::ProcessReports.new.run
  end

end