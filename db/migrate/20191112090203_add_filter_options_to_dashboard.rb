class AddFilterOptionsToDashboard < ActiveRecord::Migration[5.2]
  def change
    add_column :insight_dashboards, :can_filter_from, :boolean, default: true
    add_column :insight_dashboards, :can_filter_to, :boolean, default: true
  end
end
