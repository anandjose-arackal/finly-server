class DestroyOldTables < ActiveRecord::Migration
  def change
    drop_table :card_transaction_restrictions
    drop_table :card_budget_restrictions
  end
end
