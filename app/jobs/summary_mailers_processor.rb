class SummaryMailersProcessor

  def self.perform
    puts " ----------------------------- PERFORMING #{self.name} ------------------------------"

    SummaryMailer::Manager::ProcessReports.new.run
    SummaryMailer::CompanyAdmin::ProcessReports.new.run

    puts " ----------------------------- FINISHED #{self.name} ------------------------------"
  end

end