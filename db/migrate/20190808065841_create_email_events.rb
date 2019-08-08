class CreateEmailEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :email_events do |t|
      t.references :email, index: true, null: false
      t.string :event, index: true, null: false
      t.string :link, index: true
      t.datetime :received_at, index: true
      t.string :event_id, index: true
      t.text :payload, limit: 4294967295

      t.timestamps
    end
  end
end
