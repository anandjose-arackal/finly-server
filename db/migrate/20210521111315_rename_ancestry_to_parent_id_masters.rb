class RenameAncestryToParentIdMasters < ActiveRecord::Migration[5.2]
  def change
    # rename_column :category, :ancestry, :parent_id
    rename_column :cost_center, :ancestry, :parent_id
    rename_column :branch_locations, :ancestry, :parent_id
  end
end