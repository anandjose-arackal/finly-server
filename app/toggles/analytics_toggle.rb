class AnalyticsToggle < ApplicationToggle

  def enabled?
    # Todo change default to false
    feature_flag 'permissions/analytics#enabled', true
  end

  def maximum_reports
    feature_value 'permissions/analytics#maximum_reports', 10
  end

  def custom_reports_enabled?
    # Todo change default to false
    feature_flag 'permissions/analytics#custom_reports_enabled', true
  end

  def maximum_dashboards
    feature_value 'permissions/analytics#maximum_dashboards', 0
  end

  def drilldowns_enabled?
    # Todo change default to false
    feature_flag 'permissions/analytics#drilldowns_enabled', true
  end

  def custom_dashboards_enabled?
    # Todo change default to false
    feature_flag 'permissions/analytics#custom_dashboards_enabled', true
  end

end