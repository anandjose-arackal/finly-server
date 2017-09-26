class CreateSummaryMailConfigurations < ActiveRecord::Migration
  def change
    create_table :admin_summary_mail_configs do |t|
      t.references :user, index: true, foreign_key: true
      t.references :period, index: true, foreign_key: true
      t.integer :starting_day_of_month, index: true
      t.integer :scheduled_day_of_month, index: true
      t.string :starting_day_of_week, index: true
      t.string :scheduled_day_of_week, index: true
      t.string :scheduled_time, index: true
      t.string :application

      t.timestamps null: false
    end
  end
end
