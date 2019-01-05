class AddAddressToProcurementDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :purchase_orders, :billing_address, :text
    add_column :purchase_orders, :shipping_address, :text
    add_column :invoices, :billing_address, :text
    add_column :invoices, :shipping_address, :text
  end
end
