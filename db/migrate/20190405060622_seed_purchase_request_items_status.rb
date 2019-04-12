class SeedPurchaseRequestItemsStatus < ActiveRecord::Migration[5.2]
  def change
    PurchaseRequestItemStatus.seed_data
  end
end
