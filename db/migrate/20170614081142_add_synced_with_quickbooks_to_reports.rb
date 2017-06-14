class AddSyncedWithQuickbooksToReports < ActiveRecord::Migration
  def change
    add_column :reports, :synced_with_quickbooks, :boolean
  end
end
