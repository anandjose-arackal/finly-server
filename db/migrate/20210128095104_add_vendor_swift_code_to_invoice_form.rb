class AddVendorSwiftCodeToInvoiceForm < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :vendor_bank_account_swift_code, :string, default: ""
    add_column :invoices, :vendor_country, :string, default: ""
  end
end
