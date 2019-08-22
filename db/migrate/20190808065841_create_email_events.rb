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
    add_column :email_events, :ip_addr, :string, index: true
    add_column :email_events, :user_agent, :string, index: true
    add_column :email_events, :link_tags, :string, index: true
    rename_column :email_events, :received_at, :timestamp
  end
end
