class CreateReportSyncTypes < ActiveRecord::Migration[4.2]
  def change
    create_table :report_sync_types do |t|
      t.string :name, null: false, index: true

      t.timestamps null: false
    end
    ReportSyncType.seed_data
    ReportSyncStatus.seed_data
    add_column :reports, :sync_type_id, :integer, references: 'ReportSyncType', index: true, foreign_key: true
  end
end
