class CreateExportJobStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :export_job_statuses do |t|
      t.string :name, index: true, null: false

      t.timestamps index: true
    end
    add_column :export_jobs, :status_id, :integer, references: 'export_job_statuses', index: true, null: false
    ExportJobStatus.seed_data
  end
end
