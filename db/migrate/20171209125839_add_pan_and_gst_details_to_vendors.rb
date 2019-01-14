class AddPanAndGstDetailsToVendors < ActiveRecord::Migration[4.2]
  def change
    add_column :yes_bank_vendors, :pan, :string
    add_column :yes_bank_vendors, :tin, :string
    add_column :yes_bank_vendors, :gst, :string
  end
end