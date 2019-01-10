class SeedPurchaseOrderStatuses < ActiveRecord::Migration[4.2]
  def up
    PurchaseOrderStatus.seed_data
  end

  def down
  end
end
