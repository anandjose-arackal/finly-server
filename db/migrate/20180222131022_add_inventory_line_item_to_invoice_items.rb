class AddInventoryLineItemToInvoiceItems < ActiveRecord::Migration[4.2]
  def change
    add_column :invoice_line_items, :inventory_line_item_id, :integer, references: "InventoryLineItem", foreign_key: true, index: true
  end
end