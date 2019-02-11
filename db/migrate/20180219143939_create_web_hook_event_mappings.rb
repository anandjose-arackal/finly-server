class CreateWebHookEventMappings < ActiveRecord::Migration[4.2]
  def change
    create_table :web_hook_event_mappings do |t|
      t.references :web_hook, index: true, foreign_key: true, null: false
      t.references :web_hook_event, index: true, foreign_key: true, null: false
      t.boolean :is_deleted, default: false, index: true

      t.timestamps null: false
    end
  end
end
