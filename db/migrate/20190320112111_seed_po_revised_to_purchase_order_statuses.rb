class SeedPoRevisedToPurchaseOrderStatuses < ActiveRecord::Migration[5.2]
  def change
  	PurchaseOrderStatus.seed_data
  end
end
