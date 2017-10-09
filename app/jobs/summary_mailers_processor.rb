class SummaryMailersProcessor < ActiveJob::Base

  def perform
    return unless [0, 30].include?(DateTime.now.minute)
    SummaryMailer::Manager::ProcessReports.new.run
    SummaryMailer::CompanyAdmin::ProcessReports.new.run
  end

end