class RemoveVendorCountryFromVendor < ActiveRecord::Migration[6.0]
  def change
    remove_column :yes_bank_vendors, :vendor_country
  end
end
