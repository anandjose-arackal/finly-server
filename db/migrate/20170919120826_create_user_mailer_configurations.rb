class CreateUserMailerConfigurations < ActiveRecord::Migration
  def change
    create_table :user_mailer_configurations do |t|
      t.references :user, index: true, foreign_key: true
      t.references :user_mailer_types, index: true, foreign_key: true
      t.references :period, index: true, foreign_key: true
      t.integer :scheduled_day_of_month, index: true
      t.string :scheduled_day, index: true
      t.string :scheduled_time, index: true

      t.timestamps null: false
    end
  end
end
