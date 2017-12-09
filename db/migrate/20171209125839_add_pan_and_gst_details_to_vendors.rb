class AddPanAndGstDetailsToVendors < ActiveRecord::Migration
  def change
    add_column :yes_bank_vendors, :pan, :string
    add_column :yes_bank_vendors, :tin, :string
    add_column :yes_bank_vendors, :gst, :string
  end
end