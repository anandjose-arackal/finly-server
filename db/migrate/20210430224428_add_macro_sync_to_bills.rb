class AddMacroSyncToBills < ActiveRecord::Migration[6.0]
  def change
    ErpSyncAttempt.setup_migration(BbpsBill)
  end
end
