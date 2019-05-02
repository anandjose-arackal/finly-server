class RenameItemExpenseTypeToItemExpenseTypeIdInItems < ActiveRecord::Migration[5.2]
  def change
  	rename_column :items, :item_expense_type, :item_expense_type_id
  end
end
