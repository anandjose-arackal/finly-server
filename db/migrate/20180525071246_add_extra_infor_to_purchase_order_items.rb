class AddExtraInforToPurchaseOrderItems < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_order_items, :delivered, :integer, default: 0
    add_column :purchase_order_items, :accepted, :integer, default: 0
    add_column :purchase_order_items, :rejected, :integer, default: 0
  end
end
