class DashboardConfigApiTrim < ApplicationToggle
  def enabled?
    feature_flag 'release/dashboard_config_api_trim', false
  end
end
