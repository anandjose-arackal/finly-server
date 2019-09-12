class AddPurchaseOrderItemIdToInvoiceLineItems < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_line_items, :purchase_order_item_id, :integer, references: 'PurchaseOrderItem', foreign_key: true
    add_index :invoice_line_items, :purchase_order_item_id
  end
end
