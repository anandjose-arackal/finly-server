class SeedSupplyItemType < ActiveRecord::Migration[5.2]
  def change
    SupplyItemType.seed_data
  end
end
