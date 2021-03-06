class AllowNilCompanyIdInAnalyticsDashboard < ActiveRecord::Migration[6.0]
  def change
    change_column_null :analytics_dashboards, :company_id, true
    change_column_null :analytics_dashboards, :created_by_id, true
  end
end
