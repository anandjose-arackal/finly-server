class SeedVendorConfirmedToStatuses < ActiveRecord::Migration[5.2]
  def change
  	PurchaseOrderStatus.seed_data
  	TrailAction.seed_data
  end
end
