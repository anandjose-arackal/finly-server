class AddAnalyticsSystemToFeatureSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :feature_subscriptions, :analytics_system, :boolean
  end
end
