class SummaryMailersProcessor < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    SummaryMailer::Manager::ProcessReports.new.run
    SummaryMailer::CompanyAdmin::ProcessReports.new.run

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end

end