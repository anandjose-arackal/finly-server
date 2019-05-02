class AddBillableToBranchLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :branch_locations, :billable_location, :boolean, default: true
    add_column :branch_locations, :shippable_location, :boolean, default: true
  end
end
