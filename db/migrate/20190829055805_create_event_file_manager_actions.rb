class CreateEventFileManagerActions < ActiveRecord::Migration[5.2]
  def change
    create_table :event_file_manager_actions do |t|
      t.integer :event_workflow_id, index: true, foreign_key: true, null: false, references: 'event_workflows'
      t.references :export_template, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
