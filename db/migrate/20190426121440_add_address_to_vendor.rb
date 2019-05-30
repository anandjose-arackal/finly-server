class AddAddressToVendor < ActiveRecord::Migration[5.2]
  def change
    add_column :gstin_locations, :address, :text

    gstin_locations = GstinLocation.all

    gstin_locations.each do |g_loc|
      address = g_loc.gstin_master.address rescue nil
      if address.present?
        g_loc.update(address: address)
      end
    end
  end
end
