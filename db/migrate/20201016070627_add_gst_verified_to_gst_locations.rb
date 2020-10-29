class AddGstVerifiedToGstLocations < ActiveRecord::Migration[6.0]
  def change
    add_column :gstin_locations, :verified, :boolean
    add_column :gstin_locations, :gstin_fetch_details, :text

    add_column :bank_accounts, :verified, :boolean
  end
end
