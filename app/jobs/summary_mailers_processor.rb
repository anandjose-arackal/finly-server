class SummaryMailersProcessor < ApplicationJob

  def perform
    SummaryMailer::Manager::ProcessReports.new.run
    SummaryMailer::CompanyAdmin::ProcessReports.new.run
  end

end