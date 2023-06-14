class BbpsReminders < BaseJob
  def self.perform_job
    @logger = Logger.new "#{Rails.root}/log/reminders.log"
    @logger.info "Job ran at #{Time.now}"
  end
end