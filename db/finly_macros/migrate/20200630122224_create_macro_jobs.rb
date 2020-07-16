class CreateMacroJobs < ActiveRecord::Migration[5.2]
  def change
    create_table :macro_jobs do |t|
      t.integer :macro_id, index: true, references: 'macros', foreign_key: true, null: false
      t.datetime :started_at, index: true
      t.datetime :ended_at, index: true
      t.integer :execution_time, index: true
      t.text :request_options
      t.text :return_value, limit: 4294967295
      t.text :crash_message, limit: 4294967295
      t.text :crash_stacktrace, limit: 4294967295
      t.integer :status_id, index: true, foreign_key: true, references: 'macro_job_statuses', null: false
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
