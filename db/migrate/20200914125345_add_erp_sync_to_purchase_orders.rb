class AddErpSyncToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    ErpSyncAttempt.setup_migration(PurchaseOrder)
  end
end
