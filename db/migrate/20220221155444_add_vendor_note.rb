class AddVendorNote < ActiveRecord::Migration[6.0]
  def change
    add_column :purchase_orders, :vendor_note, :text
  end
end
