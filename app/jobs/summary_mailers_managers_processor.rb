class SummaryMailersManagersProcessor < ActiveJob::Base

  def perform
    return unless [0, 30].include?(DateTime.now.minute)
    SummaryMailer::Manager::ProcessReports.new.run
  end

end