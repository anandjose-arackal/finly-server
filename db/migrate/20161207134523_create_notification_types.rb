class CreateNotificationTypes < ActiveRecord::Migration
  def change
    create_table :notification_types do |t|
      t.string :name

      t.timestamps null: false
    end

    create_table :notification_action_types do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end
