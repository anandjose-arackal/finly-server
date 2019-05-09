class AddVendorAddressToPurchaseOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :purchase_orders, :vendor_address, :text
  end
end
