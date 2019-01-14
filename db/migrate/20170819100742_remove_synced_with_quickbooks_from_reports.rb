class RemoveSyncedWithQuickbooksFromReports < ActiveRecord::Migration[4.2]
  def change
    #first migrate the existing reports from old flag to new
    ReportSyncStatus.seed_data
    Report.all.each do |report|
      if report.synced_with_quickbooks
        report.update(sync_status_id: ReportSyncStatus.id_for(:synced))
      else
        report.update(sync_status_id: ReportSyncStatus.id_for(:not_synced))
      end
    end

    remove_column :reports, :synced_with_quickbooks, :boolean
  end
end
