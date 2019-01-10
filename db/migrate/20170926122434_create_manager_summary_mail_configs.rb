class CreateManagerSummaryMailConfigs < ActiveRecord::Migration[4.2]
  def change
    create_table :manager_summary_mail_configs do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :period, index: true, foreign_key: true, null: false
      t.integer :scheduled_day_of_month, index: true
      t.string :scheduled_day_of_week, index: true
      t.string :scheduled_time, index: true, null: false
      t.string :entity_type, index: true, null: false
      t.string :application, index: true, null: false

      t.timestamps null: false
    end
    NotifierType.seed_data
  end
end
