class SeedItemExpenseType < ActiveRecord::Migration[5.2]
  def change
  	ItemExpenseType.seed_data
  end
end
