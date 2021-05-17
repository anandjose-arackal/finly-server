class SummaryMailersProcessor < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    SummaryMailer::Manager::ProcessReports.new.run
    SummaryMailer::CompanyAdmin::ProcessReports.new.run

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end

  def self.process_em_notification
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    ActsAsTenant.without_tenant do
      FeatureSubscription.where(awaiting_approval_summary_enabled: true).includes(company: :users).each do |subscription|
        company = subscription.company
        user = company.users.active.only_admins.first
        next unless user.company.status_id == CompanyStatus.id_for(:active)
        SummaryMailer::Manager::ProcessSummaryNotification.(user, {user_id: user.id})
      end
    end
    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

  end

end