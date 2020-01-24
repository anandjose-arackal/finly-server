class AddRcmEnabledToVendors < ActiveRecord::Migration[5.2]
  def change
    add_column :yes_bank_vendors, :rcm_enabled, :boolean, default: false
    add_column :invoices, :rcm_enabled, :boolean, default: false
  end
end
