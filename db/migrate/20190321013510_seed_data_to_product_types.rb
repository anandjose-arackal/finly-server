class SeedDataToProductTypes < ActiveRecord::Migration[5.2]
  def change
  	ProductType.seed_data
  end
end
