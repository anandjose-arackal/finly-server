class SummaryMailersProcessor < ActiveJob::Base

  def perform
    SummaryMailer::Manager::ProcessReports.new.run
  end

end