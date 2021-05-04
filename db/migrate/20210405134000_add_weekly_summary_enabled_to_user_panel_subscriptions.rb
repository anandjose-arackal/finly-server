class AddWeeklySummaryEnabledToUserPanelSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :user_panel_subscriptions, :weekly_summary_enabled, :boolean, default: false
  end
end
