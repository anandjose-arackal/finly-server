class CreateImportRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :import_records do |t|
      t.uuid
      t.references :company, index: true, null: false
      t.string :import_job_id, index: true, references: 'import_jobs', null: false, foreign_key: true
      t.text :data, limit: 4294967295
      t.text :processed_data, limit: 4294967295

      t.datetime :deleted_at, index: true
      t.timestamps null: false, index: true
    end
  end
end
