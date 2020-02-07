class ChangeColumnDescriptionInPurchaseOrderItems < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_order_items, :description, "TEXT(65535) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
