class CreateApprovalTatReportExecLogs < ActiveRecord::Migration[6.0]
  def change
    create_table :approval_tat_report_exec_logs do |t|
      t.integer :company_id, null: false
      t.integer :user_id, null: false
      t.string :document_type
      t.integer :record_count
      t.integer :output_count
      t.datetime :start_time
      t.datetime :end_time
      t.integer :total_time_sec
      t.string :filter_json
      t.string :job_status
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
