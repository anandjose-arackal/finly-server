class AllowNilCompanyIdInAnalyticsDashboard < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Migration.change_column_null :analytics_dashboards, :company_id, true
  end
end
