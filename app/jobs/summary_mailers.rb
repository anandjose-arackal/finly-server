class SummaryMailers < ActiveJob::Base

  def perform
    SummaryMailer::Manager::ProcessReports.new.run
  end

end