class AddErpSyncToMoneyRequests < ActiveRecord::Migration[6.0]
  def change
    ErpSyncAttempt.setup_migration(MoneyRequest)
  end
end
