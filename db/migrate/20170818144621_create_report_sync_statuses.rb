class CreateReportSyncStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :report_sync_statuses do |t|
      t.string :name

      t.timestamps null: false
    end

    add_column :reports, :sync_status_id, :integer, references: "ReportSyncStatus", foreign_key: true, index: true
  end
end
