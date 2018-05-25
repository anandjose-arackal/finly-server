class SeedPurchaseOrderStatuses < ActiveRecord::Migration
  def up
    PurchaseOrderStatus.seed_data
  end

  def down
  end
end
