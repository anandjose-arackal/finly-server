class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.references :notification_type, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :action_user_id, :references => "User", foreign_key: true, index: true
      t.integer :amount_id, :references => "Amount", foreign_key: true, index: true
      t.integer :object_id
      t.string :object_type
      t.integer :path_object_id
      t.string :path_object_type
      t.integer :action_type_id, references: "NotificationActionType", foreign_key: true, index: true

      t.string :changed_from
      t.string :changed_to

      t.datetime :timestamp
      t.boolean :read, default: false

      t.timestamps null: false
    end
  end
end
