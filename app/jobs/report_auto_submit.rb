class ReportAutoSubmit < BaseJob

  def self.perform_job
    puts " ----------------------------- PERFORMING #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"

    today = Date.today
    interval = :daily
    if today.beginning_of_year == today
      interval = :yearly
    elsif today.beginning_of_quarter == today
      interval = :quarterly
    elsif today.beginning_of_month == today
      interval = :monthly
    elsif today.friday?
      interval = :weekly
    elsif today.day == 16 || today.beginning_of_month
      interval = :fortnightly
    end

    # Handling it for user level auto submit configuration
    auto_submit_configs = AutoSubmitConfig.enabled.includes_submitable.user_level.send(interval)

    auto_submit_configs.each do |config|
      user = config.submitable
      Reports::AutoSubmit.(nil, user: user)
    end

    puts " ----------------------------- FINISHED #{self.name} at #{Time.now.strftime("%d-%B-%Y %H:%M:%S")} ------------------------------"
  end

end