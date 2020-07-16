class CreateMacroJobLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :macro_job_logs do |t|
      t.integer :macro_id, index: true, foreign_key: true, null: false, references: 'macros'
      t.integer :macro_job_id, index: true, foreign_key: true, null: false, references: 'macro_jobs'
      t.string :log_type, index: true
      t.text :message
      t.datetime :deleted_at, index: true

      t.timestamps index: true
    end
  end
end
