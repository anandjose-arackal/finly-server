class SeedVendorStatus2 < ActiveRecord::Migration[5.2]
  def change
    VendorStatus.seed_data

    remove_column :yes_bank_vendors, :active, :boolean, default: true
  end
end
