class CreateImportJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :import_job_statuses do |t|
      t.string :name, index: true, null: false
      t.datetime :deleted_at, index: true

      t.timestamps null: false, index: true
    end
    ImportJobStatus.seed_data

    create_table :import_jobs do |t|
      t.string :name, index: true, null: false
      t.string :type, index: true
      t.integer :created_by_id, index: true, references: 'users'
      t.references :company, index: true, null: false
      t.text :request_params, limit: 4294967295
      t.datetime :completed_at, index: true
      t.integer :total_records
      t.integer :created_records
      t.integer :updated_records
      t.integer :failed_records
      t.integer :completed_records
      t.integer :completion_percentage
      t.attachment :attachment
      t.datetime :deleted_at, index: true
      t.text :options, limit: 4294967295
      t.string :description
      t.text :crash_stacktrace, limit: 4294967295
      t.integer :status_id, references: 'import_job_statuses', index: true, foreign_key: true, null: false

      t.timestamps null: false, index: true
    end
  end
end
