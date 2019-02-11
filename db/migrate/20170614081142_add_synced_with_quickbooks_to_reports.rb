class AddSyncedWithQuickbooksToReports < ActiveRecord::Migration[4.2]
  def change
    add_column :reports, :synced_with_quickbooks, :boolean
  end
end
