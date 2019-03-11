class AddLocationCodeToBranchLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :branch_locations, :location_code, :string
  end
end
