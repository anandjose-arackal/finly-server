class AddStateAndCodeToVendors < ActiveRecord::Migration
  def change
    add_column :yes_bank_vendors, :gst_registered, :boolean
    add_column :yes_bank_vendors, :state, :string
    add_column :yes_bank_vendors, :state_code, :string
  end
end
