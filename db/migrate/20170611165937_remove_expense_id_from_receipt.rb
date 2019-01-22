class RemoveExpenseIdFromReceipt < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key :receipts, :expense
    remove_index :receipts, :expense_id
    remove_column :receipts, :expense_id
  end
end
