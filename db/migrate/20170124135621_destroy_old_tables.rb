class DestroyOldTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :card_transaction_restrictions
    drop_table :card_budget_restrictions
  end
end
