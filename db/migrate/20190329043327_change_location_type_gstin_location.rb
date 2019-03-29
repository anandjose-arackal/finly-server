class ChangeLocationTypeGstinLocation < ActiveRecord::Migration[5.2]
  def change
    remove_column :gstin_locations, :location_id, :integer, references: "BranchLocation", foreign_key: true, index: true
    add_column :gstin_locations, :location, :string
  end
end
