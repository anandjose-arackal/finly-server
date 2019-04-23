class AddAncestryToBranchLocations < ActiveRecord::Migration[5.2]
  def change
    add_column :branch_locations, :ancestry, :string
    add_index :branch_locations, :ancestry
  end
end
