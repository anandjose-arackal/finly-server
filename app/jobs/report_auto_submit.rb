class ReportAutoSubmit < ActiveJob::Base

  def perform
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
    end

    # Handling it for user level auto submit configuration
    auto_submit_configs = AutoSubmitConfig.enabled.includes_submitable.user_level.send(interval)
    auto_submit_configs.each do |config|
      user = config.submitable
      Report::AutoSubmit.(nil, user: user)
    end
  end

end