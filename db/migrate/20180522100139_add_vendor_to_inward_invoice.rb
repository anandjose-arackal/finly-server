class AddVendorToInwardInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :vendor_id, :integer, references: "YesBankVendor", foreign_key: true, index: true
  end
end