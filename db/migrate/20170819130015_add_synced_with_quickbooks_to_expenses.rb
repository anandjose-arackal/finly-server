class AddSyncedWithQuickbooksToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :synced_with_quickbooks, :boolean
  end
end
