class AddVendorToInwardInvoice < ActiveRecord::Migration
  def change
    add_column :invoices, :vendor_id, :integer, references: "YesBankVendor", foreign_key: true, index: true
  end
end