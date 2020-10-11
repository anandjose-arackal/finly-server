class AddErpSyncToExpenses < ActiveRecord::Migration[5.2]
  def change
    ErpSyncAttempt.setup_migration(Report)
  end
end
