class CreateAnalyticsDashboardSchedules < ActiveRecord::Migration[6.0]
  def change
    create_table :analytics_dashboard_schedules do |t|
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'
      t.integer :analytics_dashboard_id, index: true, foreign_key: true, references: 'analytics_dashboards', null: false
      t.datetime :start_date, index: true
      t.datetime :end_date, index: true
      t.integer :frequency, index: true
      t.integer :hour, index: true
      t.integer :minute, index: true
      t.integer :day_of_the_week, index: true
      t.integer :day_of_the_month, index: true
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
