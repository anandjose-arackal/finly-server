class SeedProcurementStatuses2 < ActiveRecord::Migration[4.2]
  def change
    PurchaseOrderStatus.seed_data
  end
end
