class IncreaseSizeOfAddressesInBranchLocations < ActiveRecord::Migration[5.2]
  def change
    change_column :branch_locations, :address_1, :text
    change_column :branch_locations, :address_2, :text
  end
end
