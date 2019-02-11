class CreateEventConfigurations < ActiveRecord::Migration[4.2]
  def change
    create_table :event_configurations do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :event, index: true, foreign_key: true, null: false
      t.boolean :allow_push_notification
      t.boolean :allow_mailer

      t.timestamps null: false
    end
  end
end
