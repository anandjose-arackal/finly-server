class AddFeatureFlagToAnalyticsDashboard < ActiveRecord::Migration[6.0]
  def change
    add_column :analytics_dashboards, :feature_toggle, :string
  end
end
