class CreateSystemLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :system_logs do |t|
      t.integer :log_resource_id, null: false, index: true
      t.string :log_resource_type, null: false, index: true
      t.integer :type_id, references: 'SystemMessageType', index: true, foreign_key: true, null: false
      t.text :value, null: false

      t.timestamps null: false
    end
  end
end
