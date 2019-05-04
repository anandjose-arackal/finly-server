class RenameBillingAddressPurchaseOrder < ActiveRecord::Migration[5.2]
  def change
    change_column :purchase_orders, :billing_address, "TEXT(65535) CHARACTER SET utf8 COLLATE utf8_bin"
    change_column :purchase_orders, :shipping_address, "TEXT(65535) CHARACTER SET utf8 COLLATE utf8_bin"
  end
end
