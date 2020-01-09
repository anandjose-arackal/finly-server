class CreateEventWorkflows < ActiveRecord::Migration[5.2]
  def change
    create_table :event_workflows do |t|
      t.string :uuid, index: true, limit: 36, null: false
      t.string :name, null: false
      t.text :description, null: false
      t.integer :trigger_type, index: true, null: false
      t.text :conditions
      t.string :model_class, index: true, null: false
      t.string :event_key, index: true
      t.boolean :personal, index: true, default: true
      t.integer :user_id, index: true, foreign_key: true, null: false, references: 'users'
      t.integer :company_id, index: true, foreign_key: true, null: false, references: 'companies'

      t.timestamps index: true, null: false
    end
  end
end
