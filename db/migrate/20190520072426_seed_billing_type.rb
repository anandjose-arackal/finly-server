class SeedBillingType < ActiveRecord::Migration[5.2]
  def change
    BillingType.seed_data
  end
end
