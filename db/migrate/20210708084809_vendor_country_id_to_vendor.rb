class VendorCountryIdToVendor < ActiveRecord::Migration[6.0]
  def change
    add_column :yes_bank_vendors, :vendor_country_id, :integer
  end
end
