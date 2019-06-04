class AddGstToPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_order_items, :cgst, :decimal, precision: 10, scale: 5
    add_column :purchase_order_items, :sgst, :decimal, precision: 10, scale: 5
    add_column :purchase_order_items, :igst, :decimal, precision: 10, scale: 5
    add_column :invoice_line_items, :sgst, :decimal, precision: 10, scale: 5
    add_column :invoice_line_items, :cgst, :decimal, precision: 10, scale: 5
    add_column :invoice_line_items, :igst, :decimal, precision: 10, scale: 5
  end
end
