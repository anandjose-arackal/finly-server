class CreateTrackerNotifications < ActiveRecord::Migration[4.2]
  def change
    create_table :tracker_notifications do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.references :company, index: true, foreign_key: true, null: false
      t.string :app, index: true
      t.string :device, index: true
      t.string :view, index: true

      t.timestamps null: false
    end
  end
end
