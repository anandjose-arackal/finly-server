class CreateExportJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :export_jobs do |t|
      t.string :name, index: true, null: false
      t.string :export_type, index: true
      t.integer :created_by_id, index: true, references: 'users'
      t.references :company, index: true, null: false
      t.text :request_params, limit: 4294967295
      t.datetime :completed_at, index: true
      t.integer :total_records, index: true
      t.integer :completed_records, index: true
      t.integer :completion_percentage, index: true
      t.attachment :attachment

      t.timestamps index: true
    end
  end
end