class AddSyncedWithQuickbooksToExpenses < ActiveRecord::Migration[4.2]
  def change
    add_column :expenses, :synced_with_quickbooks, :boolean

    # moving all already synced reports and their expenses to synced state
    Report.where(sync_status_id: ReportSyncStatus.id_for(:synced)).each do |report|
      report.expenses.update_all(synced_with_quickbooks: true)
    end
  end
end
