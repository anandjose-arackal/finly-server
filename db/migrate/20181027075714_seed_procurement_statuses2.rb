class SeedProcurementStatuses2 < ActiveRecord::Migration
  def change
    PurchaseOrderStatus.seed_data
  end
end
