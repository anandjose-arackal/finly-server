class ChangeColumnTypeInPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
  	change_column :purchase_order_items, :delivered, :decimal
  	change_column :purchase_order_items, :accepted, :decimal
  	change_column :purchase_order_items, :rejected, :decimal
  end
end
