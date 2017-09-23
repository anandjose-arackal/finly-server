class CreateSummaryMailConfigurations < ActiveRecord::Migration
  def change
    create_table :summary_mail_configurations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :period, index: true, foreign_key: true
      t.integer :scheduled_day_of_month, index: true
      t.string :scheduled_day_of_week, index: true
      t.string :scheduled_time, index: true
      t.boolean :personal
      t.string :application

      t.timestamps null: false
    end
  end
end
