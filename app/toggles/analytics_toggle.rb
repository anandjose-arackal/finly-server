class AnalyticsToggle < ApplicationToggle

  def enabled?
    feature_flag 'permissions/analytics#enabled', false
  end

  def maximum_reports
    feature_value 'permissions/analytics#maximum_reports', 10
  end

  def custom_reports_enabled?
    feature_flag 'permissions/analytics#custom_reports_enabled', false
  end

  def maximum_dashboards
    feature_value 'permissions/analytics#maximum_dashboards', 0
  end

  def drilldowns_enabled?
    feature_flag 'permissions/analytics#drilldowns_enabled', false
  end

  def custom_dashboards_enabled?
    feature_flag 'permissions/analytics#custom_dashboards_enabled', false
  end

end