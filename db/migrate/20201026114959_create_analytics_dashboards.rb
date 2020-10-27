class CreateAnalyticsDashboards < ActiveRecord::Migration[6.0]
  def change
    create_table :analytics_dashboards do |t|
      t.string :app, index: true, null: false
      t.integer :company_id, index: true, null: false, references: 'companies', foreign_key: true
      t.integer :created_by_id, index: true, null: false, references: 'users', foreign_key: true
      t.string :name, index: true, null: false
      t.text :description
      t.boolean :default, index: true, default: false
      t.text :reports, null: false
      t.boolean :is_system_dashboard, index: true
      t.string :system_dashboard_id, index: true, references: 'analytics_dashboards', foreign_key: true
      t.text :feature_subscriptions

      t.datetime :deleted_at, index: true
      t.timestamps index: true
    end
  end
end
