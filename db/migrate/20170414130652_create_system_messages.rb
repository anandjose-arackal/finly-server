class CreateSystemMessages < ActiveRecord::Migration
  def change
    create_table :system_messages do |t|
      t.text :content, null: false
      t.integer :system_message_type_id, references: 'SystemMessageType', null: false, foreign_key: true, index: true
      t.references :messagable, polymorphic: true

      t.timestamps null: false
    end
  end
end
