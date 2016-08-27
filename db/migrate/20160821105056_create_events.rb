class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.boolean :has_push_notification, null:false
      t.boolean :has_mailer, null:false
      t.boolean :configurable_push_notification, null:false
      t.boolean :configurable_mailer, null:false

      t.timestamps null: false
    end
  end
end
