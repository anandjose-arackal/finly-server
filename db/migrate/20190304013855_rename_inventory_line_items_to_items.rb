class RenameInventoryLineItemsToItems < ActiveRecord::Migration[5.2]
  def change
    rename_table :inventory_line_items, :items
  end
end
