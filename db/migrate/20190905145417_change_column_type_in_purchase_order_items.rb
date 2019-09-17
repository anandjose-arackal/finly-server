class ChangeColumnTypeInPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
  	change_column :purchase_order_items, :delivered, :decimal, precision: 20, scale: 5, default: 0
  	change_column :purchase_order_items, :accepted, :decimal, precision: 20, scale: 5, default: 0
  	change_column :purchase_order_items, :rejected, :decimal, precision: 20, scale: 5, default: 0
  end
end
