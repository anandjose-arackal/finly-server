class AddErpSyncToPayments < ActiveRecord::Migration[5.2]
  def change
    ErpSyncAttempt.setup_migration(Payment)
  end
end
