class CreateAnalyticsDashboardScheduleUserMappings < ActiveRecord::Migration[6.0]
  def change
    create_table :analytics_dashboard_schedule_user_mappings do |t|
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.integer :analytics_dashboard_id, foreign_key: true, references: 'analytics_dashboards', null: false,
                index: {name: 'index_analytics_dashboard_schedule_user_mappings_on_dashboard_id'}
      t.integer :user_id, index: true, foreign_key: true, null: false, references: 'users'
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
