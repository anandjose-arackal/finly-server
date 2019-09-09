class AddVendorLocationIdToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :vendor_location_id, :integer
  end
end
