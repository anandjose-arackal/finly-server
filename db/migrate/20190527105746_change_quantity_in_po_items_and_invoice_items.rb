class ChangeQuantityInPoItemsAndInvoiceItems < ActiveRecord::Migration[5.2]
  def change
  	change_column :purchase_order_items, :quantity, :decimal, :precision => 20, :scale => 5
  	change_column :invoice_line_items, :quantity, :decimal, :precision => 20, :scale => 5
  end
end
