class AddItemExpenseTypeToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :item_expense_type, :integer, references: 'ItemExpenseType', foreign_key: true
    add_index :items, :item_expense_type
  end
end
