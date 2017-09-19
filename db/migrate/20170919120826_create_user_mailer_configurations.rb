class CreateUserMailerConfigurations < ActiveRecord::Migration
  def change
    create_table :user_mailer_configurations do |t|
      t.references :user, index: true, foreign_key: true
      t.string :scheduled_at_time, index: true
      # t.date
      t.references :period, index: true, foreign_key: true
      t.references :user_mailer_types, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
