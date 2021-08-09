class AddNameAndGstinToInvoiceForm < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :billing_address_name, :string, default: ""
    add_column :invoices, :billing_address_gstin, :string, default: ""
    add_column :invoices, :shipping_address_name, :string, default: ""
    add_column :invoices, :shipping_address_gstin, :string, default: ""
  end
end
