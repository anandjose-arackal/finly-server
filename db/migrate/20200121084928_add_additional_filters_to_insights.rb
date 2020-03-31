class AddAdditionalFiltersToInsights < ActiveRecord::Migration[5.2]
  def change
    rename_column :insight_dashboards, :can_filter_from, :can_filter_date
    remove_column :insight_dashboards, :can_filter_to
    add_column :insight_dashboards, :can_filter_policy, :boolean, default: false
    add_column :insight_dashboards, :can_filter_department, :boolean, default: false
    add_column :insight_dashboards, :can_filter_location, :boolean, default: false
    add_column :insight_dashboards, :can_filter_cost_center, :boolean, default: false
    add_column :insight_dashboards, :can_filter_category, :boolean, default: false
    InsightDashboard.update_all can_filter_policy: true,
                                can_filter_department: true,
                                can_filter_location: true,
                                can_filter_cost_center: true,
                                can_filter_category: true
  end
end
